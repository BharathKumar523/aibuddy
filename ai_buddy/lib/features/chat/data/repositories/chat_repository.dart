import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/chat_stream_event.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/data/repositories/mock_chat_repository.dart';

/// Conversations and messages.
///
/// Futures throw an `AppException` on failure. Streams report failures as a
/// [ChatStreamFailed] event (or a stream error). Cancelling the stream
/// subscription stops generation; in Phase 6 that closes the HTTP
/// connection and the server stops the OpenAI request.
abstract interface class ChatRepository {
  /// The signed-in user's conversations, most recent first.
  Future<List<Conversation>> listConversations();

  Future<Conversation> createConversation();

  /// Messages of one conversation, oldest first.
  Future<List<ChatMessage>> listMessages(String conversationId);

  /// Sends a user message and streams the AI reply.
  Stream<ChatStreamEvent> sendMessage({
    required String conversationId,
    required String content,
    required String clientMessageId,
  });

  /// Generates a failed or stopped assistant message again, in place.
  Stream<ChatStreamEvent> retryMessage({
    required String conversationId,
    required String messageId,
  });
}

/// Phase 5: an in-memory mock with realistic streaming.
/// Phase 6 replaces this with the API + SSE implementation; nothing above
/// the repository changes.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // A fresh store per signed-in user, so data never leaks across accounts.
  ref.watch(currentUserProvider.select((user) => user?.id));
  return MockChatRepository();
}, name: 'chatRepositoryProvider');
