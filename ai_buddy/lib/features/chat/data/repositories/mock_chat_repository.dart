import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/chat_stream_event.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/data/repositories/mock_responses.dart';

/// In-memory [ChatRepository] that behaves like the real backend:
/// network latency, word-by-word streaming, titles from the first message,
/// failures, retry and cancellation.
///
/// A message containing the word "fail" fails part-way through, so the
/// error and Retry UI can be tried; retrying it succeeds.
class MockChatRepository implements ChatRepository {
  MockChatRepository({
    this.latency = const Duration(milliseconds: 400),
    this.chunkDelay = const Duration(milliseconds: 30),
    bool seed = true,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now {
    if (seed) _seed();
  }

  final Duration latency;
  final Duration chunkDelay;
  final DateTime Function() _now;

  final Map<String, Conversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};
  int _sequence = 0;

  String _nextId(String prefix) => '$prefix-${++_sequence}';

  @override
  Future<List<Conversation>> listConversations() async {
    await Future<void>.delayed(latency);
    return _conversations.values.toList()
      ..sort((a, b) => b.sortTime.compareTo(a.sortTime));
  }

  @override
  Future<Conversation> createConversation() async {
    await Future<void>.delayed(latency);
    final now = _now();
    final conversation = Conversation(
      id: _nextId('conv'),
      createdAt: now,
      updatedAt: now,
    );
    _conversations[conversation.id] = conversation;
    _messages[conversation.id] = <ChatMessage>[];
    return conversation;
  }

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async {
    await Future<void>.delayed(latency);
    final messages = _messages[conversationId];
    if (messages == null) {
      throw const NotFoundException(message: 'Conversation not found.');
    }
    return List.unmodifiable(messages);
  }

  @override
  Stream<ChatStreamEvent> sendMessage({
    required String conversationId,
    required String content,
    required String clientMessageId,
  }) async* {
    await Future<void>.delayed(latency);
    final messages = _messages[conversationId];
    if (messages == null) {
      yield const ChatStreamEvent.failed(
        error: MessageError(code: 'NOT_FOUND', message: 'Conversation not found.'),
        retryable: false,
      );
      return;
    }

    final userMessage = ChatMessage(
      id: _nextId('msg'),
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: _now(),
      clientMessageId: clientMessageId,
    );
    messages.add(userMessage);

    final assistant = ChatMessage(
      id: _nextId('msg'),
      conversationId: conversationId,
      role: MessageRole.assistant,
      status: MessageStatus.streaming,
      createdAt: _now(),
    );
    messages.add(assistant);

    yield ChatStreamEvent.started(
      userMessage: userMessage,
      assistantMessageId: assistant.id,
    );
    yield* _generate(
      conversationId,
      assistant.id,
      prompt: content,
      mayFail: content.toLowerCase().contains('fail'),
    );
  }

  @override
  Stream<ChatStreamEvent> retryMessage({
    required String conversationId,
    required String messageId,
  }) async* {
    await Future<void>.delayed(latency);
    final messages = _messages[conversationId];
    final index = messages?.indexWhere((m) => m.id == messageId) ?? -1;
    if (messages == null || index < 0) {
      yield const ChatStreamEvent.failed(
        error: MessageError(code: 'NOT_FOUND', message: 'Message not found.'),
        retryable: false,
      );
      return;
    }

    final prompt = messages
        .take(index)
        .lastWhere(
          (m) => m.isUser,
          orElse: () => messages[index],
        )
        .content;

    messages[index] = messages[index].copyWith(
      content: '',
      status: MessageStatus.streaming,
      error: null,
    );
    yield ChatStreamEvent.started(assistantMessageId: messageId);
    // Retries succeed, so the failure demo can be recovered from.
    yield* _generate(conversationId, messageId, prompt: prompt, mayFail: false);
  }

  Stream<ChatStreamEvent> _generate(
    String conversationId,
    String messageId, {
    required String prompt,
    required bool mayFail,
  }) async* {
    final chunks = RegExp(r'\S+\s*')
        .allMatches(MockResponses.replyFor(prompt))
        .map((match) => match.group(0)!)
        .toList();
    final failAt = mayFail ? chunks.length ~/ 3 : -1;
    final buffer = StringBuffer();
    var finished = false;

    try {
      for (var i = 0; i < chunks.length; i++) {
        if (i == failAt) {
          const error = MessageError(
            code: 'AI_PROVIDER_ERROR',
            message: 'The AI service is temporarily unavailable. Please try again.',
          );
          _store(conversationId, messageId, buffer.toString(), MessageStatus.failed,
              error: error);
          finished = true;
          yield ChatStreamEvent.failed(error: error, messageId: messageId);
          return;
        }
        await Future<void>.delayed(chunkDelay);
        buffer.write(chunks[i]);
        yield ChatStreamEvent.delta(messageId: messageId, text: chunks[i]);
      }

      final message = _store(
        conversationId,
        messageId,
        buffer.toString().trimRight(),
        MessageStatus.completed,
      );
      finished = true;
      yield ChatStreamEvent.completed(
        message: message,
        conversation: _touch(conversationId),
      );
    } finally {
      // Runs when the listener cancels (Stop button / screen closed), like
      // the backend saving the partial reply as "cancelled".
      if (!finished) {
        _store(conversationId, messageId, buffer.toString(), MessageStatus.cancelled);
      }
    }
  }

  ChatMessage _store(
    String conversationId,
    String messageId,
    String content,
    MessageStatus status, {
    MessageError? error,
  }) {
    final messages = _messages[conversationId]!;
    final index = messages.indexWhere((m) => m.id == messageId);
    final updated = messages[index].copyWith(
      content: content,
      status: status,
      error: error,
    );
    messages[index] = updated;
    return updated;
  }

  /// Updates title (from the first user message), counts and timestamps.
  Conversation _touch(String conversationId) {
    final conversation = _conversations[conversationId]!;
    final messages = _messages[conversationId]!;
    final now = _now();
    var title = conversation.title;
    if (title == Conversation.defaultTitle) {
      final first = messages.firstWhere((m) => m.isUser).content.trim();
      final oneLine = first.replaceAll(RegExp(r'\s+'), ' ');
      title = oneLine.length > 40 ? '${oneLine.substring(0, 40).trimRight()}…' : oneLine;
    }
    final updated = conversation.copyWith(
      title: title,
      updatedAt: now,
      lastMessageAt: now,
      messageCount: messages.length,
    );
    _conversations[conversationId] = updated;
    return updated;
  }

  void _seed() {
    final now = _now();
    void add(String title, Duration ago, List<(MessageRole, String)> turns) {
      final id = _nextId('conv');
      final time = now.subtract(ago);
      _messages[id] = [
        for (final (role, text) in turns)
          ChatMessage(
            id: _nextId('msg'),
            conversationId: id,
            role: role,
            content: text,
            createdAt: time,
          ),
      ];
      _conversations[id] = Conversation(
        id: id,
        title: title,
        createdAt: time,
        updatedAt: time,
        lastMessageAt: time,
        messageCount: turns.length,
      );
    }

    add('Debounce function in Dart', const Duration(hours: 3), [
      (MessageRole.user, 'Write a Dart function that debounces a callback.'),
      (MessageRole.assistant, MockResponses.replyFor('debounce').trimRight()),
    ]);
    add('Weekend trip to Goa', const Duration(days: 2), [
      (MessageRole.user, 'Plan a 2-day trip to Goa on a budget.'),
      (MessageRole.assistant, MockResponses.replyFor('goa').trimRight()),
    ]);
  }
}
