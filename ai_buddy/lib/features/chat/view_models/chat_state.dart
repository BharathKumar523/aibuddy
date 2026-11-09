import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';

part 'chat_state.freezed.dart';

/// Everything the chat screen renders.
@freezed
abstract class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState({
    /// The open conversation; null for a new chat that hasn't been sent yet.
    Conversation? conversation,

    /// Oldest first.
    @Default(<ChatMessage>[]) List<ChatMessage> messages,

    /// Loading an existing conversation's messages.
    @Default(false) bool isLoadingMessages,

    /// Loading the messages failed; shown with a Retry button.
    String? loadError,

    /// The assistant message currently being generated, if any.
    String? activeMessageId,
  }) = _ChatState;

  bool get isGenerating => activeMessageId != null;

  /// A fresh chat with nothing in it: shows the welcome view.
  bool get isEmpty => messages.isEmpty && !isLoadingMessages && loadError == null;

  String get title => conversation?.title ?? Conversation.defaultTitle;
}
