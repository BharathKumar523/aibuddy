import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/app_typography.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/features/settings/views/widgets/theme_mode_selector.dart';
import 'package:ai_buddy/features/system/views/widgets/health_check_card.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/app_snackbar.dart';
import 'package:ai_buddy/shared/widgets/app_text_field.dart';
import 'package:ai_buddy/shared/widgets/state_views.dart';

/// Living style guide: every token and shared widget in one scrollable page.
///
/// Used to verify Phase 2 (theme, components, network stack) and kept as a
/// reference while building later screens.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const <Widget>[
                _Section(title: 'Theme', child: ThemeModeSelector()),
                _Section(title: 'Network', child: HealthCheckCard()),
                _Section(title: 'Colors', child: _ColorSwatches()),
                _Section(title: 'Typography', child: _TypographySamples()),
                _Section(title: 'Buttons', child: _ButtonSamples()),
                _Section(title: 'Text fields', child: _TextFieldSamples()),
                _Section(title: 'Chat bubbles', child: _BubbleSamples()),
                _Section(title: 'States', child: _StateSamples()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: context.textStyles.labelMedium?.copyWith(letterSpacing: 1),
          ),
          Gap.h12,
          child,
        ],
      ),
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = context.palette;
    final swatches = <(String, Color, Color)>[
      ('Primary', c.primary, c.onPrimary),
      ('Container', c.primaryContainer, c.onPrimaryContainer),
      ('Accent', p.accent, Colors.black),
      ('Surface', c.surface, c.onSurface),
      ('Muted', p.surfaceMuted, c.onSurface),
      ('Error', c.error, c.onError),
      ('Success', p.success, Colors.white),
      ('Code', p.codeBackground, p.onCodeBackground),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final (name, background, foreground) in swatches)
          Container(
            width: 104,
            height: 64,
            padding: const EdgeInsets.all(AppSpacing.sm),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: p.border),
            ),
            child: Text(
              name,
              style: context.textStyles.labelMedium?.copyWith(color: foreground),
            ),
          ),
      ],
    );
  }
}

class _TypographySamples extends StatelessWidget {
  const _TypographySamples();

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Headline medium', style: t.headlineMedium),
        Text('Title large', style: t.titleLarge),
        Text('Title medium', style: t.titleMedium),
        Text('Body large: how can I help you today?', style: t.bodyLarge),
        Text('Body medium: secondary paragraph text.', style: t.bodyMedium),
        Text('Body small: captions and timestamps', style: t.bodySmall),
        Gap.h8,
        Text(
          "final greeting = 'Hello, AI Buddy';",
          style: AppTypography.code.copyWith(color: context.colors.onSurface),
        ),
      ],
    );
  }
}

class _ButtonSamples extends StatelessWidget {
  const _ButtonSamples();

  @override
  Widget build(BuildContext context) {
    void tapped(String which) => AppSnackbar.show(context, '$which tapped');

    return Column(
      children: <Widget>[
        AppButton(label: 'Primary', onPressed: () => tapped('Primary')),
        Gap.h8,
        AppButton(
          label: 'Secondary with icon',
          icon: Icons.add_rounded,
          variant: AppButtonVariant.secondary,
          onPressed: () => tapped('Secondary'),
        ),
        Gap.h8,
        const AppButton(label: 'Loading', isLoading: true, onPressed: null),
        Gap.h8,
        const AppButton(label: 'Disabled', onPressed: null),
        Gap.h8,
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: 'Success toast',
                variant: AppButtonVariant.text,
                onPressed: () => AppSnackbar.show(
                  context,
                  'Saved successfully',
                  type: SnackbarType.success,
                ),
              ),
            ),
            Expanded(
              child: AppButton(
                label: 'Error toast',
                variant: AppButtonVariant.text,
                onPressed: () => AppSnackbar.show(
                  context,
                  'Could not reach the server',
                  type: SnackbarType.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextFieldSamples extends StatelessWidget {
  const _TextFieldSamples();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        Gap.h12,
        AppTextField(
          label: 'Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        Gap.h12,
        AppTextField(
          label: 'Name',
          prefixIcon: Icons.person_outline_rounded,
          errorText: 'Name must be at least 2 characters',
        ),
      ],
    );
  }
}

class _BubbleSamples extends StatelessWidget {
  const _BubbleSamples();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final body = context.textStyles.bodyLarge;

    Widget bubble({
      required String text,
      required Color background,
      required Color foreground,
      required bool alignEnd,
    }) {
      return Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadius.lgAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Text(text, style: body?.copyWith(color: foreground)),
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        bubble(
          text: 'Explain SSE in one sentence.',
          background: p.userBubble,
          foreground: p.onUserBubble,
          alignEnd: true,
        ),
        Gap.h8,
        bubble(
          text: 'Server-Sent Events keep one HTTP response open so the server '
              'can push text to the client as it is generated.',
          background: p.assistantBubble,
          foreground: p.onAssistantBubble,
          alignEnd: false,
        ),
      ],
    );
  }
}

class _StateSamples extends StatelessWidget {
  const _StateSamples();

  @override
  Widget build(BuildContext context) {
    Widget frame(Widget child) => SizedBox(
          height: 220,
          child: Card(child: child),
        );

    return Column(
      children: <Widget>[
        frame(const LoadingView(message: 'Loading conversations…')),
        Gap.h12,
        frame(
          const EmptyView(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No conversations yet',
            message: 'Start a new chat to see it here.',
          ),
        ),
        Gap.h12,
        frame(
          ErrorView(
            message: 'Unable to reach the server.',
            onRetry: () => AppSnackbar.show(context, 'Retry tapped'),
          ),
        ),
      ],
    );
  }
}
