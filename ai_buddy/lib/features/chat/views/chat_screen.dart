import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/chat/data/models/conversation.dart';
import 'package:ai_buddy/features/chat/view_models/chat_state.dart';
import 'package:ai_buddy/features/chat/view_models/chat_view_model.dart';
import 'package:ai_buddy/features/chat/views/widgets/chat_input.dart';
import 'package:ai_buddy/features/chat/views/widgets/conversations_panel.dart';
import 'package:ai_buddy/features/chat/views/widgets/message_list.dart';
import 'package:ai_buddy/features/chat/views/widgets/welcome_view.dart';
import 'package:ai_buddy/shared/widgets/app_snackbar.dart';
import 'package:ai_buddy/shared/widgets/state_views.dart';

/// The main chat screen.
///
/// Phones: the history is a drawer. Tablets/landscape (≥ 900 px): it's a
/// permanent side panel. Messages are width-limited for readability.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const double wideLayoutBreakpoint = 900;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  ChatViewModel get _viewModel => ref.read(chatViewModelProvider.notifier);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    unawaited(_viewModel.send(text));
    // Bring the new message into view (offset 0 = newest; the list is reversed).
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppSnackbar.show(context, 'Copied to clipboard');
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _openConversation(Conversation conversation) {
    _closeDrawer();
    unawaited(_viewModel.openConversation(conversation));
  }

  void _newChat() {
    _closeDrawer();
    _viewModel.newChat();
  }

  void _push(String path) {
    _closeDrawer();
    unawaited(context.push(path));
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatViewModelProvider);
    final user = ref.watch(currentUserProvider);
    final isWide =
        MediaQuery.sizeOf(context).width >= ChatScreen.wideLayoutBreakpoint;

    final panel = ConversationsPanel(
      selectedId: chat.conversation?.id,
      onSelected: _openConversation,
      onNewChat: _newChat,
      onOpenProfile: () => _push(RoutePaths.profile),
      onOpenSettings: () => _push(RoutePaths.settings),
    );

    final conversationArea = Column(
      children: <Widget>[
        Expanded(child: _buildBody(chat, user?.name)),
        ChatInput(
          isGenerating: chat.isGenerating,
          enabled: !chat.isLoadingMessages && chat.loadError == null,
          onSend: _send,
          onStop: _viewModel.stop,
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide ? null : Drawer(child: panel),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isWide
            ? null
            : IconButton(
                tooltip: 'Conversations',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: Text(chat.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.edit_square),
            onPressed: chat.conversation == null && chat.messages.isEmpty
                ? null
                : _newChat,
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: <Widget>[
                SizedBox(width: 300, child: panel),
                const VerticalDivider(width: 1),
                Expanded(child: conversationArea),
              ],
            )
          : conversationArea,
    );
  }

  Widget _buildBody(ChatState chat, String? userName) {
    if (chat.isLoadingMessages) {
      return const LoadingView(message: 'Loading messages…');
    }
    final loadError = chat.loadError;
    if (loadError != null) {
      return ErrorView(
        title: "Couldn't open this chat",
        message: loadError,
        onRetry: () => unawaited(_viewModel.retryLoad()),
      );
    }
    if (chat.messages.isEmpty) {
      return WelcomeView(userName: userName, onPromptSelected: _send);
    }
    return MessageList(
      messages: chat.messages,
      controller: _scrollController,
      isGenerating: chat.isGenerating,
      onCopy: (text) => unawaited(_copy(text)),
      onRetry: (messageId) => unawaited(_viewModel.retry(messageId)),
    );
  }
}
