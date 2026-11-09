import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/shared/widgets/app_logo.dart';

/// Shared layout for the login and registration screens: logo, title,
/// subtitle and a centred, width-limited, scrollable form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBackButton ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Center(child: AppLogo(size: 64)),
                  Gap.h24,
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.textStyles.headlineMedium,
                  ),
                  Gap.h8,
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                  Gap.h32,
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
