import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/views/widgets/message_bubble.dart';

/// The scrolling message list.
///
/// It is a reversed list: offset 0 is the newest message at the bottom.
/// New messages and streamed text therefore stay in view without manual
/// scrolling while the user is at the bottom, and reading older messages
/// isn't interrupted. A "jump to latest" button appears when scrolled up.
class MessageList extends StatefulWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.controller,
    required this.isGenerating,
    required this.onCopy,
    required this.onRetry,
  });

  /// Oldest first.
  final List<ChatMessage> messages;
  final ScrollController controller;
  final bool isGenerating;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onRetry;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  static const double _showJumpAfter = 240;
  bool _showJumpButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final show = widget.controller.hasClients &&
        widget.controller.offset > _showJumpAfter;
    if (show != _showJumpButton) setState(() => _showJumpButton = show);
  }

  Future<void> _jumpToLatest() => widget.controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: widget.controller,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            return Center(
              key: ValueKey<String>(message.id),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: MessageBubble(
                  message: message,
                  onCopy: widget.onCopy,
                  onRetry: widget.onRetry,
                  canRetry: !widget.isGenerating,
                ),
              ),
            );
          },
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: AnimatedScale(
            scale: _showJumpButton ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: FloatingActionButton.small(
              heroTag: null,
              tooltip: 'Jump to latest',
              onPressed: _jumpToLatest,
              child: const Icon(Icons.arrow_downward_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
