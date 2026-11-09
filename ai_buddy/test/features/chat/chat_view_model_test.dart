import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/chat_stream_event.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/view_models/chat_state.dart';
import 'package:ai_buddy/features/chat/view_models/chat_view_model.dart';

import '../../helpers/fakes.dart';

/// A repository whose streams the test drives by hand, one event at a time.
class FakeChatRepository implements ChatRepository {
  final DateTime now = DateTime.utc(2026, 11, 9, 10);

  Object? createError;
  Object? listMessagesError;
  Map<String, List<ChatMessage>> storedMessages = {};

  final List<({String conversationId, String content, String clientMessageId})> sent = [];
  final List<String> retried = [];
  StreamController<ChatStreamEvent>? stream;
  bool cancelled = false;
  int createCalls = 0;

  late final Conversation created = Conversation(id: 'conv-1', createdAt: now, updatedAt: now);

  Stream<ChatStreamEvent> _newStream() {
    cancelled = false;
    final controller = StreamController<ChatStreamEvent>(onCancel: () => cancelled = true);
    stream = controller;
    return controller.stream;
  }

  @override
  Future<Conversation> createConversation() async {
    createCalls++;
    final error = createError;
    if (error != null) throw error;
    return created;
  }

  @override
  Future<List<Conversation>> listConversations() async => <Conversation>[];

  @override
  Future<List<ChatMessage>> listMessages(String conversationId) async {
    final error = listMessagesError;
    if (error != null) throw error;
    return storedMessages[conversationId] ?? <ChatMessage>[];
  }

  @override
  Stream<ChatStreamEvent> sendMessage({
    required String conversationId,
    required String content,
    required String clientMessageId,
  }) {
    sent.add((conversationId: conversationId, content: content, clientMessageId: clientMessageId));
    return _newStream();
  }

  @override
  Stream<ChatStreamEvent> retryMessage({
    required String conversationId,
    required String messageId,
  }) {
    retried.add(messageId);
    return _newStream();
  }

  ChatMessage serverMessage(String id, MessageRole role, String content,
          {MessageStatus status = MessageStatus.completed, String? clientMessageId}) =>
      ChatMessage(
        id: id,
        conversationId: created.id,
        role: role,
        content: content,
        status: status,
        createdAt: now,
        clientMessageId: clientMessageId,
      );
}

void main() {
  late FakeChatRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeChatRepository();
    container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(repository),
        currentUserProvider.overrideWithValue(testUser),
      ],
      retry: (retryCount, error) => null,
    );
  });

  tearDown(() => container.dispose());

  ChatViewModel vm() => container.read(chatViewModelProvider.notifier);
  ChatState state() => container.read(chatViewModelProvider);
  ChatMessage assistant() => state().messages.last;

  /// Lets queued stream events and futures run.
  Future<void> settle() => pumpEventQueue();

  /// Waits for buffered stream text to be applied.
  Future<void> flush() => Future<void>.delayed(ChatViewModel.flushInterval * 2);

  /// Sends [text] in a new chat and acknowledges it like the server would.
  Future<void> sendAndStart(String text) async {
    await vm().send(text);
    await settle();
    final clientId = repository.sent.last.clientMessageId;
    repository.stream!.add(
      ChatStreamEvent.started(
        userMessage: repository.serverMessage('u1', MessageRole.user, text,
            clientMessageId: clientId),
        assistantMessageId: 'a1',
      ),
    );
    await settle();
  }

  group('send', () {
    test('ignores empty input', () async {
      expect(await vm().send('   '), isFalse);
      expect(state().messages, isEmpty);
    });

    test('shows the user message and a pending reply immediately', () async {
      final accepted = vm().send('  Hello  ');

      expect(state().messages, hasLength(2));
      expect(state().messages.first.content, 'Hello');
      expect(state().messages.first.isLocal, isTrue);
      expect(assistant().status, MessageStatus.pending);
      expect(assistant().isAwaitingFirstChunk, isTrue);
      expect(state().isGenerating, isTrue);
      expect(await accepted, isTrue);
    });

    test('creates the conversation for a new chat, then streams into it', () async {
      await vm().send('Hello');
      await settle();

      expect(repository.createCalls, 1);
      expect(state().conversation, repository.created);
      expect(repository.sent.single.conversationId, 'conv-1');
      expect(repository.sent.single.content, 'Hello');
    });

    test('a full reply: ids swapped, text streamed, message completed', () async {
      await sendAndStart('Hello');

      expect(state().messages.map((m) => m.id), ['u1', 'a1']);
      expect(state().activeMessageId, 'a1');

      repository.stream!
        ..add(const ChatStreamEvent.delta(messageId: 'a1', text: 'Hi '))
        ..add(const ChatStreamEvent.delta(messageId: 'a1', text: 'there'));
      await settle();
      expect(assistant().content, isEmpty, reason: 'text is batched');

      await flush();
      expect(assistant().content, 'Hi there');
      expect(assistant().status, MessageStatus.streaming);

      final renamed = repository.created.copyWith(title: 'Hello');
      repository.stream!.add(
        ChatStreamEvent.completed(
          message: repository.serverMessage('a1', MessageRole.assistant, 'Hi there!'),
          conversation: renamed,
        ),
      );
      await settle();

      expect(assistant().content, 'Hi there!');
      expect(assistant().status, MessageStatus.completed);
      expect(state().isGenerating, isFalse);
      expect(state().title, 'Hello');
    });

    test('refuses a second message while a reply is generating', () async {
      await sendAndStart('First');

      expect(await vm().send('Second'), isFalse);
      expect(repository.sent, hasLength(1));
    });
  });

  group('failures', () {
    test('a stream error keeps the partial text and marks it failed', () async {
      await sendAndStart('Hello');
      repository.stream!
        ..add(const ChatStreamEvent.delta(messageId: 'a1', text: 'Partial'))
        ..add(
          const ChatStreamEvent.failed(
            error: MessageError(code: 'AI_PROVIDER_ERROR', message: 'AI is down'),
            messageId: 'a1',
          ),
        );
      await settle();

      expect(assistant().content, 'Partial');
      expect(assistant().status, MessageStatus.failed);
      expect(assistant().error?.message, 'AI is down');
      expect(assistant().isRetryable, isTrue);
      expect(state().isGenerating, isFalse);
    });

    test('a connection that closes early is reported as interrupted', () async {
      await sendAndStart('Hello');
      await repository.stream!.close();
      await settle();

      expect(assistant().status, MessageStatus.failed);
      expect(assistant().error?.code, 'STREAM_INTERRUPTED');
    });

    test('retry regenerates the failed message in place', () async {
      await sendAndStart('Hello');
      repository.stream!.add(
        const ChatStreamEvent.failed(error: MessageError(), messageId: 'a1'),
      );
      await settle();

      await vm().retry('a1');

      expect(repository.retried, ['a1']);
      expect(assistant().status, MessageStatus.pending);
      expect(assistant().content, isEmpty);
      expect(state().isGenerating, isTrue);

      repository.stream!
        ..add(const ChatStreamEvent.started(assistantMessageId: 'a1'))
        ..add(
          ChatStreamEvent.completed(
            message: repository.serverMessage('a1', MessageRole.assistant, 'Done'),
          ),
        );
      await settle();

      expect(state().messages, hasLength(2));
      expect(assistant().content, 'Done');
      expect(assistant().status, MessageStatus.completed);
    });

    test('if the chat could not be created, retry sends the prompt again', () async {
      repository.createError = const NetworkException();
      await vm().send('Hello');
      await settle();

      expect(assistant().status, MessageStatus.failed);
      expect(assistant().error?.message, const NetworkException().message);
      expect(repository.sent, isEmpty);

      repository.createError = null;
      await vm().retry(assistant().id);
      await settle();

      expect(repository.sent.single.content, 'Hello');
      expect(state().messages, hasLength(2), reason: 'old attempt replaced');
    });
  });

  group('stop', () {
    test('cancels the stream and keeps what was received', () async {
      await sendAndStart('Hello');
      repository.stream!.add(const ChatStreamEvent.delta(messageId: 'a1', text: 'Half'));
      await settle();

      vm().stop();
      await settle();

      expect(repository.cancelled, isTrue);
      expect(assistant().content, 'Half');
      expect(assistant().status, MessageStatus.cancelled);
      expect(assistant().isRetryable, isTrue);
      expect(state().isGenerating, isFalse);
    });
  });

  group('conversations', () {
    final existing = Conversation(
      id: 'conv-9',
      title: 'Old chat',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    test('opening a conversation loads its messages', () async {
      repository.storedMessages['conv-9'] = [
        ChatMessage(
          id: 'm1',
          conversationId: 'conv-9',
          role: MessageRole.user,
          content: 'Earlier question',
          createdAt: DateTime.utc(2026),
        ),
      ];

      final loading = vm().openConversation(existing);
      expect(state().isLoadingMessages, isTrue);
      await loading;

      expect(state().title, 'Old chat');
      expect(state().messages.single.content, 'Earlier question');
      expect(state().isLoadingMessages, isFalse);
    });

    test('a failed load shows an error that can be retried', () async {
      repository.listMessagesError = const ServerException();
      await vm().openConversation(existing);

      expect(state().loadError, const ServerException().message);

      repository.listMessagesError = null;
      await vm().retryLoad();
      expect(state().loadError, isNull);
    });

    test('new chat clears the screen and stops any reply', () async {
      await sendAndStart('Hello');

      vm().newChat();
      await settle();

      expect(state().messages, isEmpty);
      expect(state().conversation, isNull);
      expect(state().isGenerating, isFalse);
      expect(repository.cancelled, isTrue);
    });
  });
}
