import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/features/chat/data/models/chat_message.dart';
import 'package:ai_buddy/features/chat/views/widgets/message_content.dart';
import 'package:ai_buddy/features/chat/views/widgets/typing_indicator.dart';

/// One message. User messages are right-aligned bubbles; assistant replies
/// are full-width markdown with copy / retry actions.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onRetry,
    this.canRetry = true,
  });

  final ChatMessage message;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onRetry;

  /// False while another reply is generating.
  final bool canRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: message.isUser
          ? _UserBubble(message: message, onCopy: onCopy)
          : _AssistantMessage(
              message: message,
              onCopy: onCopy,
              onRetry: canRetry ? () => onRetry(message.id) : null,
            ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message, required this.onCopy});

  final ChatMessage message;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        const SizedBox(width: AppSpacing.xxxl),
        Flexible(
          // Long-press copies the message.
          child: Semantics(
            onLongPressHint: 'Copy message',
            child: GestureDetector(
              onLongPress: () => onCopy(message.content),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: palette.userBubble,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                    bottomRight: Radius.circular(AppRadius.sm / 2),
                  ),
                ),
                child: Text(
                  message.content,
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: palette.onUserBubble,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({
    required this.message,
    required this.onCopy,
    required this.onRetry,
  });

  final ChatMessage message;
  final ValueChanged<String> onCopy;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hasContent = message.content.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _AssistantAvatar(),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (message.isAwaitingFirstChunk)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: TypingIndicator(),
                )
              else if (hasContent)
                MessageContent(content: message.content, onCopy: onCopy),
              switch (message.status) {
                MessageStatus.failed => _StatusNote(
                    icon: Icons.error_outline_rounded,
                    color: context.colors.error,
                    text: message.error?.message ??
                        'Something went wrong. Please try again.',
                    onRetry: onRetry,
                  ),
                MessageStatus.cancelled => _StatusNote(
                    icon: Icons.stop_circle_outlined,
                    color: context.palette.mutedText,
                    text: 'Response stopped.',
                    onRetry: onRetry,
                  ),
                MessageStatus.completed when hasContent => _Actions(
                    onCopy: () => onCopy(message.content),
                  ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ],
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: AppRadius.smAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colors.primary, colors.primaryContainer],
        ),
      ),
      child: Icon(Icons.auto_awesome_rounded, size: 16, color: colors.onPrimary),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: IconButton(
        tooltip: 'Copy message',
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        color: context.palette.mutedText,
        icon: const Icon(Icons.copy_rounded),
        onPressed: onCopy,
      ),
    );
  }
}

class _StatusNote extends StatelessWidget {
  const _StatusNote({
    required this.icon,
    required this.color,
    required this.text,
    required this.onRetry,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          Text(text, style: context.textStyles.bodyMedium?.copyWith(color: color)),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
