import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/chat_stream_event.dart';
import 'package:ai_buddy/features/chat/data/repositories/mock_chat_repository.dart';

void main() {
  late MockChatRepository repository;

  setUp(() {
    repository = MockChatRepository(latency: Duration.zero, chunkDelay: Duration.zero);
  });

  test('starts with seeded conversations, newest first', () async {
    final conversations = await repository.listConversations();

    expect(conversations, hasLength(2));
    expect(conversations.first.title, 'Debounce function in Dart');
    expect(
      conversations.first.sortTime.isAfter(conversations.last.sortTime),
      isTrue,
    );
  });

  test('streams start → deltas → complete and stores both messages', () async {
    final conversation = await repository.createConversation();

    final events = await repository
        .sendMessage(
          conversationId: conversation.id,
          content: 'Explain JWT please',
          clientMessageId: 'client-1',
        )
        .toList();

    expect(events.first, isA<ChatStreamStarted>());
    expect(events.whereType<ChatStreamDelta>(), isNotEmpty);
    final completed = events.last as ChatStreamCompleted;
    expect(completed.message.status, MessageStatus.completed);
    expect(completed.message.content, contains('JSON Web Token'));

    // The streamed text adds up to the final message.
    final streamed = events.whereType<ChatStreamDelta>().map((e) => e.text).join();
    expect(streamed.trimRight(), completed.message.content);

    // Title comes from the first message.
    expect(completed.conversation?.title, 'Explain JWT please');

    final stored = await repository.listMessages(conversation.id);
    expect(stored.map((m) => m.role), [MessageRole.user, MessageRole.assistant]);
    expect(stored.first.clientMessageId, 'client-1');
  });

  test('a message containing "fail" fails part-way; retry succeeds', () async {
    final conversation = await repository.createConversation();

    final events = await repository
        .sendMessage(
          conversationId: conversation.id,
          content: 'please fail',
          clientMessageId: 'c',
        )
        .toList();

    final failed = events.last as ChatStreamFailed;
    expect(failed.error.code, 'AI_PROVIDER_ERROR');
    expect(failed.retryable, isTrue);
    final assistantId = (events.first as ChatStreamStarted).assistantMessageId;
    var stored = await repository.listMessages(conversation.id);
    expect(stored.last.status, MessageStatus.failed);

    final retryEvents = await repository
        .retryMessage(conversationId: conversation.id, messageId: assistantId)
        .toList();

    expect(retryEvents.last, isA<ChatStreamCompleted>());
    stored = await repository.listMessages(conversation.id);
    expect(stored, hasLength(2), reason: 'retry regenerates in place');
    expect(stored.last.status, MessageStatus.completed);
  });

  test('cancelling the stream stores the partial reply as cancelled', () async {
    final conversation = await repository.createConversation();
    final stream = repository.sendMessage(
      conversationId: conversation.id,
      content: 'Explain JWT',
      clientMessageId: 'c',
    );

    await for (final event in stream) {
      if (event is ChatStreamDelta) break; // cancels the subscription
    }
    await pumpEventQueue();

    final stored = await repository.listMessages(conversation.id);
    expect(stored.last.status, MessageStatus.cancelled);
    expect(stored.last.content, isNotEmpty);
  });

  test('unknown conversation fails without throwing', () async {
    final events = await repository
        .sendMessage(conversationId: 'nope', content: 'hi', clientMessageId: 'c')
        .toList();

    expect((events.single as ChatStreamFailed).retryable, isFalse);
    await expectLater(
      repository.listMessages('nope'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
