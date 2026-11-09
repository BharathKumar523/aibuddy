import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';

part 'chat_stream_event.freezed.dart';

/// Events emitted while an AI reply is generated.
///
/// They mirror the backend's Server-Sent Events one to one
/// (`message_start`, `message_delta`, `message_complete`, `error`), so the
/// ViewModel works the same with the mock (Phase 5) and the real SSE
/// stream (Phase 6).
@freezed
sealed class ChatStreamEvent with _$ChatStreamEvent {
  /// `message_start`: the server stored the user message (null on retry)
  /// and created the assistant message that will be filled in.
  const factory ChatStreamEvent.started({
    ChatMessage? userMessage,
    required String assistantMessageId,
  }) = ChatStreamStarted;

  /// `message_delta`: the next piece of reply text.
  const factory ChatStreamEvent.delta({
    required String messageId,
    required String text,
  }) = ChatStreamDelta;

  /// `message_complete`: the final stored message, plus the updated
  /// conversation (new title, lastMessageAt).
  const factory ChatStreamEvent.completed({
    required ChatMessage message,
    Conversation? conversation,
  }) = ChatStreamCompleted;

  /// `error`: generation failed. Partial text received so far is kept.
  const factory ChatStreamEvent.failed({
    required MessageError error,
    String? messageId,
    @Default(true) bool retryable,
  }) = ChatStreamFailed;
}
