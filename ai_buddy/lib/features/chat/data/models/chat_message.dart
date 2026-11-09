import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Who wrote a message. Names match the backend's `role` values.
enum MessageRole { user, assistant, system }

/// Lifecycle of a message. Names match the backend's `status` values.
///
/// pending → (streaming) → completed | failed | cancelled
enum MessageStatus { pending, streaming, completed, failed, cancelled }

/// Why an assistant message failed (backend `error` object).
@freezed
abstract class MessageError with _$MessageError {
  const factory MessageError({
    @Default('UNKNOWN_ERROR') String code,
    @Default('Something went wrong. Please try again.') String message,
  }) = _MessageError;

  factory MessageError.fromJson(Map<String, dynamic> json) =>
      _$MessageErrorFromJson(json);
}

/// One message in a conversation.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String conversationId,
    required MessageRole role,
    @Default('') String content,
    @Default(MessageStatus.completed) MessageStatus status,
    required DateTime createdAt,

    /// Client-generated id for user messages; the server rejects a second
    /// message with the same id, which prevents duplicate submissions.
    String? clientMessageId,
    MessageError? error,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Prefix for ids created on the device before the server assigns one.
  static const String localIdPrefix = 'local-';

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  /// Not yet acknowledged by the server.
  bool get isLocal => id.startsWith(localIdPrefix);

  /// Waiting for the first chunk of the reply.
  bool get isAwaitingFirstChunk =>
      isAssistant &&
      (status == MessageStatus.pending ||
          (status == MessageStatus.streaming && content.isEmpty));

  /// Failed or stopped assistant replies can be generated again.
  bool get isRetryable =>
      isAssistant &&
      (status == MessageStatus.failed || status == MessageStatus.cancelled);
}
