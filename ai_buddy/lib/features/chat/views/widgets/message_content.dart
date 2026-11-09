import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/app_typography.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/features/chat/utils/message_content_parser.dart';
import 'package:ai_buddy/features/chat/views/widgets/code_block.dart';

/// Renders an assistant reply: markdown prose and code blocks.
class MessageContent extends StatelessWidget {
  const MessageContent({super.key, required this.content, required this.onCopy});

  final String content;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final segments = parseMessageContent(content);
    final styleSheet = _styleSheet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final segment in segments)
          switch (segment) {
            MarkdownSegment(:final text) => MarkdownBody(
                data: text,
                selectable: true,
                softLineBreak: true,
                styleSheet: styleSheet,
              ),
            CodeSegment(:final code, :final language) => CodeBlock(
                code: code,
                language: language,
                onCopy: onCopy,
              ),
          },
      ],
    );
  }

  MarkdownStyleSheet _styleSheet(BuildContext context) {
    final theme = context.theme;
    final text = context.textStyles;
    final palette = context.palette;
    final body = text.bodyLarge?.copyWith(color: palette.onAssistantBubble);

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: body,
      listBullet: body,
      h1: text.headlineSmall,
      h2: text.titleLarge,
      h3: text.titleMedium,
      strong: const TextStyle(fontWeight: FontWeight.w700),
      code: AppTypography.code.copyWith(
        color: context.colors.onSurface,
        backgroundColor: palette.surfaceMuted,
      ),
      blockSpacing: AppSpacing.md,
      blockquote: body?.copyWith(color: palette.mutedText),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      blockquoteDecoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: AppRadius.smAll,
        border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
      ),
      tableBorder: TableBorder.all(color: palette.border),
      tableHead: text.titleSmall,
      tableBody: text.bodyMedium,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border)),
      ),
    );
  }
}
