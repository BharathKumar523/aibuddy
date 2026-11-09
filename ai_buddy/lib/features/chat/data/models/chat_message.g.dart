// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageError _$MessageErrorFromJson(Map<String, dynamic> json) =>
    _MessageError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message:
          json['message'] as String? ??
          'Something went wrong. Please try again.',
    );

Map<String, dynamic> _$MessageErrorToJson(_MessageError instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String? ?? '',
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.completed,
  createdAt: DateTime.parse(json['createdAt'] as String),
  clientMessageId: json['clientMessageId'] as String?,
  error: json['error'] == null
      ? null
      : MessageError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'clientMessageId': instance.clientMessageId,
      'error': instance.error,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

const _$MessageStatusEnumMap = {
  MessageStatus.pending: 'pending',
  MessageStatus.streaming: 'streaming',
  MessageStatus.completed: 'completed',
  MessageStatus.failed: 'failed',
  MessageStatus.cancelled: 'cancelled',
};
