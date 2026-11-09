import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/app_typography.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';

/// A fenced code block: dark panel, language label, copy button, and
/// horizontal scrolling so long lines never wrap or overflow.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    required this.onCopy,
    this.language,
  });

  final String code;
  final String? language;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = palette.onCodeBackground;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.codeBackground,
        borderRadius: AppRadius.mdAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white.withValues(alpha: 0.06),
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    language ?? 'code',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  color: foreground.withValues(alpha: 0.8),
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () => onCopy(code),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SelectableText(
              code,
              style: AppTypography.code.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
