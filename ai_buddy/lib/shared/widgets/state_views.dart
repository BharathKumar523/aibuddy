import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';

/// Full-area loading state.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (text != null) ...<Widget>[
            Gap.h16,
            Text(text, style: context.textStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Full-area error state with an optional retry action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return _CenteredMessage(
      icon: Icons.error_outline_rounded,
      iconColor: context.colors.error,
      title: title,
      message: message,
      action: retry == null
          ? null
          : AppButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.secondary,
              expand: false,
              onPressed: retry,
            ),
    );
  }
}

/// Full-area empty state.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      icon: icon,
      iconColor: context.palette.mutedText,
      title: title,
      message: message,
      action: action,
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final body = message;
    final cta = action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 48, color: iconColor),
              Gap.h16,
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textStyles.titleMedium,
              ),
              if (body != null) ...<Widget>[
                Gap.h8,
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ],
              if (cta != null) ...<Widget>[Gap.h24, cta],
            ],
          ),
        ),
      ),
    );
  }
}
