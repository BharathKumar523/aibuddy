import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// A chat thread in the history list.
@freezed
abstract class Conversation with _$Conversation {
  const Conversation._();

  const factory Conversation({
    required String id,
    @Default('New chat') String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastMessageAt,
    @Default(0) int messageCount,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  static const String defaultTitle = 'New chat';

  /// Used to order the history list, most recent first.
  DateTime get sortTime => lastMessageAt ?? updatedAt;
}
