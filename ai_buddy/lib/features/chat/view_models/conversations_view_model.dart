import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository.dart';

/// The chat history list (drawer / side panel).
///
/// Rebuilt from scratch when the signed-in user changes, so a new account
/// never sees the previous one's chats.
final conversationsViewModelProvider =
    AsyncNotifierProvider<ConversationsViewModel, List<Conversation>>(
  ConversationsViewModel.new,
  name: 'conversationsViewModelProvider',
);

class ConversationsViewModel extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    ref.watch(currentUserProvider.select((user) => user?.id));
    final conversations =
        await ref.watch(chatRepositoryProvider).listConversations();
    return _sorted(conversations);
  }

  /// Pull-to-refresh / Retry.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Inserts or updates a conversation (new chat, new title, new message)
  /// and moves it to the top, without reloading the whole list.
  void upsert(Conversation conversation) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      _sorted(<Conversation>[
        conversation,
        ...current.where((c) => c.id != conversation.id),
      ]),
    );
  }

  static List<Conversation> _sorted(List<Conversation> conversations) {
    return List<Conversation>.of(conversations)
      ..sort((a, b) => b.sortTime.compareTo(a.sortTime));
  }
}
