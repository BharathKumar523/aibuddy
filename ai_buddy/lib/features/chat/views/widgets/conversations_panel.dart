import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/core/utils/date_labels.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/view_models/conversations_view_model.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/state_views.dart';

/// Chat history: "New chat", the conversation list, and the account footer.
/// Used as the drawer on phones and as a fixed side panel on wide screens.
class ConversationsPanel extends ConsumerWidget {
  const ConversationsPanel({
    super.key,
    required this.selectedId,
    required this.onSelected,
    required this.onNewChat,
    required this.onOpenProfile,
    required this.onOpenSettings,
  });

  final String? selectedId;
  final ValueChanged<Conversation> onSelected;
  final VoidCallback onNewChat;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsViewModelProvider);
    final user = ref.watch(currentUserProvider);
    final viewModel = ref.read(conversationsViewModelProvider.notifier);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              key: const Key('new_chat_button'),
              label: 'New chat',
              icon: Icons.add_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: onNewChat,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text('Recent', style: context.textStyles.labelMedium),
          ),
          Expanded(child: _buildList(context, conversations, viewModel)),
          const Divider(),
          if (user != null)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: context.colors.primaryContainer,
                foregroundColor: context.colors.onPrimaryContainer,
                child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase()),
              ),
              title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: onOpenProfile,
              trailing: IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: onOpenSettings,
              ),
            ),
          Gap.h8,
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AsyncValue<List<Conversation>> conversations,
    ConversationsViewModel viewModel,
  ) {
    // Keep showing the current list while a refresh is in flight.
    final list = conversations.value;
    if (list == null) {
      if (conversations.hasError && !conversations.isLoading) {
        return ErrorView(
          title: "Couldn't load chats",
          message: ErrorMapper.map(conversations.error!).message,
          onRetry: viewModel.refresh,
        );
      }
      return const LoadingView();
    }

    if (list.isEmpty) {
      return const EmptyView(
        icon: Icons.forum_outlined,
        title: 'No conversations yet',
        message: 'Your chats will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final conversation = list[index];
          return ListTile(
            key: ValueKey<String>(conversation.id),
            selected: conversation.id == selectedId,
            selectedTileColor: context.colors.primaryContainer.withValues(alpha: 0.5),
            title: Text(
              conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(relativeDateLabel(conversation.sortTime)),
            onTap: () => onSelected(conversation),
          );
        },
      ),
    );
  }
}
