import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/config/app_constants.dart';
import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/app_logo.dart';

/// Shown while the stored session is being restored.
///
/// The router leaves this screen on its own once the session resolves. If
/// the server can't be reached, the user stays signed in and can retry, or
/// choose to sign out.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const AppLogo(size: 88),
                  Gap.h24,
                  Text(
                    AppConstants.appName,
                    style: context.textStyles.headlineMedium,
                  ),
                  Gap.h32,
                  if (session.hasError && !session.isLoading)
                    _RestoreFailed(
                      message: ErrorMapper.map(session.error!).message,
                      onRetry: () =>
                          ref.read(sessionViewModelProvider.notifier).retry(),
                      onSignOut: () => unawaited(
                        ref.read(sessionViewModelProvider.notifier).signOut(),
                      ),
                    )
                  else
                    const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestoreFailed extends StatelessWidget {
  const _RestoreFailed({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
        Gap.h24,
        AppButton(
          label: 'Try again',
          icon: Icons.refresh_rounded,
          onPressed: onRetry,
        ),
        Gap.h8,
        AppButton(
          label: 'Sign out',
          variant: AppButtonVariant.text,
          onPressed: onSignOut,
        ),
      ],
    );
  }
}
