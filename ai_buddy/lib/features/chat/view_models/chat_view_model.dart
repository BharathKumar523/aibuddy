import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:ai_buddy/core/config/app_constants.dart';
import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/chat_stream_event.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/view_models/chat_state.dart';
import 'package:ai_buddy/features/chat/view_models/conversations_view_model.dart';

/// Drives the chat screen: sending, streaming, stopping, retrying and
/// switching conversations.
///
/// Reset automatically when the signed-in user changes.
final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  ChatViewModel.new,
  name: 'chatViewModelProvider',
);

class ChatViewModel extends Notifier<ChatState> {
  /// Streamed text is applied at most this often. Re-rendering markdown on
  /// every word would make the list janky on long replies.
  static const Duration flushInterval = Duration(milliseconds: 40);

  static const Uuid _uuid = Uuid();

  StreamSubscription<ChatStreamEvent>? _subscription;
  Timer? _flushTimer;
  final StringBuffer _pendingText = StringBuffer();

  /// Id of the assistant message being generated (local id until the
  /// server's `message_start` replaces it).
  String? _streamMessageId;

  /// Bumped whenever the open conversation changes, so results of older
  /// requests are ignored.
  int _epoch = 0;

  ChatRepository get _repository => ref.read(chatRepositoryProvider);

  @override
  ChatState build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.onDispose(_abortGeneration);
    return const ChatState();
  }

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  /// Starts an empty chat (the welcome view).
  void newChat() {
    _abortGeneration();
    _epoch++;
    state = const ChatState();
  }

  /// Opens a conversation from the history list and loads its messages.
  Future<void> openConversation(Conversation conversation) async {
    if (state.conversation?.id == conversation.id && state.loadError == null) {
      return;
    }
    _abortGeneration();
    await _load(conversation);
  }

  /// Retries loading after an error.
  Future<void> retryLoad() async {
    final conversation = state.conversation;
    if (conversation != null) await _load(conversation);
  }

  Future<void> _load(Conversation conversation) async {
    final epoch = ++_epoch;
    state = ChatState(conversation: conversation, isLoadingMessages: true);
    try {
      final messages = await _repository.listMessages(conversation.id);
      if (!ref.mounted || epoch != _epoch) return;
      state = state.copyWith(messages: messages, isLoadingMessages: false);
    } on Object catch (error, stackTrace) {
      if (!ref.mounted || epoch != _epoch) return;
      state = state.copyWith(
        isLoadingMessages: false,
        loadError: ErrorMapper.map(error, stackTrace).message,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sending
  // ---------------------------------------------------------------------------

  /// Sends [text]. Returns false when it was not accepted (empty, too long,
  /// or a reply is still being generated). Double taps can't send twice.
  Future<bool> send(String text) async {
    final content = text.trim();
    if (content.isEmpty ||
        content.length > AppConstants.maxMessageLength ||
        state.isGenerating ||
        state.isLoadingMessages) {
      return false;
    }

    final epoch = _epoch;
    final clientMessageId = _uuid.v4();
    final now = DateTime.now();
    final conversationId = state.conversation?.id ?? '';

    // Optimistic UI: the user's bubble and an empty assistant bubble (typing
    // indicator) appear immediately.
    final userMessage = ChatMessage(
      id: '${ChatMessage.localIdPrefix}$clientMessageId',
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: now,
      clientMessageId: clientMessageId,
    );
    final assistantMessage = ChatMessage(
      id: '${ChatMessage.localIdPrefix}reply-$clientMessageId',
      conversationId: conversationId,
      role: MessageRole.assistant,
      status: MessageStatus.pending,
      createdAt: now,
    );
    _streamMessageId = assistantMessage.id;
    state = state.copyWith(
      messages: <ChatMessage>[...state.messages, userMessage, assistantMessage],
      activeMessageId: assistantMessage.id,
    );

    var conversation = state.conversation;
    if (conversation == null) {
      try {
        conversation = await _repository.createConversation();
      } on Object catch (error, stackTrace) {
        if (_isStale(epoch, assistantMessage.id)) return true;
        _finishWithError(_toMessageError(ErrorMapper.map(error, stackTrace)));
        return true;
      }
      if (_isStale(epoch, assistantMessage.id)) return true;
      state = state.copyWith(conversation: conversation);
      ref.read(conversationsViewModelProvider.notifier).upsert(conversation);
    }

    _listen(
      _repository.sendMessage(
        conversationId: conversation.id,
        content: content,
        clientMessageId: clientMessageId,
      ),
    );
    return true;
  }

  /// Generates a failed or stopped reply again.
  Future<void> retry(String messageId) async {
    if (state.isGenerating) return;
    final messages = state.messages;
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0 || !messages[index].isRetryable) return;

    final conversation = state.conversation;
    final message = messages[index];

    // The request never reached the server: send the user's prompt again.
    if (message.isLocal || conversation == null) {
      final promptIndex = index - 1;
      if (promptIndex < 0 || !messages[promptIndex].isUser) return;
      final prompt = messages[promptIndex].content;
      state = state.copyWith(
        messages: List<ChatMessage>.of(messages)..removeRange(promptIndex, index + 1),
      );
      await send(prompt);
      return;
    }

    _streamMessageId = message.id;
    _updateMessage(
      message.id,
      (m) => m.copyWith(content: '', status: MessageStatus.pending, error: null),
    );
    state = state.copyWith(activeMessageId: message.id);
    _listen(
      _repository.retryMessage(
        conversationId: conversation.id,
        messageId: message.id,
      ),
    );
  }

  /// Stops the reply being generated. Text received so far is kept and the
  /// message can be retried.
  void stop() {
    final messageId = _streamMessageId;
    if (!state.isGenerating || messageId == null) return;
    final subscription = _subscription;
    _subscription = null;
    unawaited(subscription?.cancel());
    _flush();
    _updateMessage(messageId, (m) => m.copyWith(status: MessageStatus.cancelled));
    _finish();
  }

  // ---------------------------------------------------------------------------
  // Stream handling
  // ---------------------------------------------------------------------------

  void _listen(Stream<ChatStreamEvent> stream) {
    unawaited(_subscription?.cancel());
    _subscription = stream.listen(
      _onEvent,
      onError: (Object error, StackTrace stackTrace) {
        _finishWithError(_toMessageError(ErrorMapper.map(error, stackTrace)));
      },
      onDone: _onDone,
    );
  }

  void _onEvent(ChatStreamEvent event) {
    if (_streamMessageId == null) return;
    switch (event) {
      case ChatStreamStarted(:final userMessage, :final assistantMessageId):
        _onStarted(userMessage, assistantMessageId);
      case ChatStreamDelta(:final text):
        _pendingText.write(text);
        _flushTimer ??= Timer(flushInterval, _flush);
      case ChatStreamCompleted(:final message, :final conversation):
        _onCompleted(message, conversation);
      case ChatStreamFailed(:final error):
        _finishWithError(error);
    }
  }

  /// Swaps the optimistic local ids for the server's ids.
  void _onStarted(ChatMessage? serverUserMessage, String assistantMessageId) {
    final localAssistantId = _streamMessageId;
    final messages = <ChatMessage>[
      for (final m in state.messages)
        if (serverUserMessage != null &&
            m.isUser &&
            m.clientMessageId == serverUserMessage.clientMessageId)
          serverUserMessage
        else if (m.id == localAssistantId)
          m.copyWith(id: assistantMessageId, conversationId: serverUserMessage?.conversationId ?? m.conversationId)
        else
          m,
    ];
    _streamMessageId = assistantMessageId;
    state = state.copyWith(messages: messages, activeMessageId: assistantMessageId);
  }

  void _onCompleted(ChatMessage message, Conversation? conversation) {
    final messageId = _streamMessageId;
    _clearPending();
    if (messageId != null) _updateMessage(messageId, (_) => message);
    _finish();
    if (conversation != null) {
      state = state.copyWith(conversation: conversation);
      ref.read(conversationsViewModelProvider.notifier).upsert(conversation);
    }
  }

  void _onDone() {
    // The stream closed without completing or failing: the connection dropped.
    if (_streamMessageId == null) return;
    _finishWithError(
      const MessageError(
        code: 'STREAM_INTERRUPTED',
        message: 'The connection was interrupted. Please try again.',
      ),
    );
  }

  void _finishWithError(MessageError error) {
    final messageId = _streamMessageId;
    if (messageId == null) return;
    _flush();
    _updateMessage(
      messageId,
      (m) => m.copyWith(status: MessageStatus.failed, error: error),
    );
    _finish();
  }

  /// Applies buffered stream text to the message.
  void _flush() {
    _flushTimer?.cancel();
    _flushTimer = null;
    final messageId = _streamMessageId;
    if (_pendingText.isEmpty || messageId == null || !ref.mounted) return;
    final text = _pendingText.toString();
    _pendingText.clear();
    _updateMessage(
      messageId,
      (m) => m.copyWith(content: m.content + text, status: MessageStatus.streaming),
    );
  }

  void _clearPending() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _pendingText.clear();
  }

  void _finish() {
    _clearPending();
    _subscription = null;
    _streamMessageId = null;
    state = state.copyWith(activeMessageId: null);
  }

  /// Stops listening without touching state (conversation switch, dispose).
  void _abortGeneration() {
    final subscription = _subscription;
    _subscription = null;
    unawaited(subscription?.cancel());
    _clearPending();
    _streamMessageId = null;
  }

  bool _isStale(int epoch, String assistantMessageId) =>
      !ref.mounted || epoch != _epoch || _streamMessageId != assistantMessageId;

  void _updateMessage(String id, ChatMessage Function(ChatMessage) update) {
    state = state.copyWith(
      messages: <ChatMessage>[
        for (final m in state.messages) m.id == id ? update(m) : m,
      ],
    );
  }

  static MessageError _toMessageError(AppException error) => MessageError(
        code: error.code ?? 'UNKNOWN_ERROR',
        message: error.message,
      );
}
