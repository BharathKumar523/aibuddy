import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';

/// Inline error message for forms and cards, announced to screen readers.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: colors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, color: colors.error, size: 20),
            Gap.w12,
            Expanded(
              child: Text(
                message,
                style: context.textStyles.bodyMedium?.copyWith(color: colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
