import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_colors.dart';

/// App-specific colors that `ColorScheme` has no slot for (chat bubbles,
/// code blocks, success/warning).
///
/// Registered as a [ThemeExtension], so it switches with the theme and
/// animates smoothly between light and dark.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.userBubble,
    required this.onUserBubble,
    required this.assistantBubble,
    required this.onAssistantBubble,
    required this.codeBackground,
    required this.onCodeBackground,
    required this.success,
    required this.warning,
    required this.accent,
    required this.mutedText,
    required this.border,
    required this.surfaceMuted,
  });

  factory AppPalette.fromTokens(AppColorTokens t) => AppPalette(
        userBubble: t.userBubble,
        onUserBubble: t.onUserBubble,
        assistantBubble: t.assistantBubble,
        onAssistantBubble: t.onAssistantBubble,
        codeBackground: t.codeBackground,
        onCodeBackground: t.onCodeBackground,
        success: t.success,
        warning: t.warning,
        accent: t.accent,
        mutedText: t.textSecondary,
        border: t.border,
        surfaceMuted: t.surfaceMuted,
      );

  final Color userBubble;
  final Color onUserBubble;
  final Color assistantBubble;
  final Color onAssistantBubble;
  final Color codeBackground;
  final Color onCodeBackground;
  final Color success;
  final Color warning;
  final Color accent;
  final Color mutedText;
  final Color border;
  final Color surfaceMuted;

  @override
  AppPalette copyWith({
    Color? userBubble,
    Color? onUserBubble,
    Color? assistantBubble,
    Color? onAssistantBubble,
    Color? codeBackground,
    Color? onCodeBackground,
    Color? success,
    Color? warning,
    Color? accent,
    Color? mutedText,
    Color? border,
    Color? surfaceMuted,
  }) {
    return AppPalette(
      userBubble: userBubble ?? this.userBubble,
      onUserBubble: onUserBubble ?? this.onUserBubble,
      assistantBubble: assistantBubble ?? this.assistantBubble,
      onAssistantBubble: onAssistantBubble ?? this.onAssistantBubble,
      codeBackground: codeBackground ?? this.codeBackground,
      onCodeBackground: onCodeBackground ?? this.onCodeBackground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      accent: accent ?? this.accent,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    );
  }

  @override
  AppPalette lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      userBubble: mix(userBubble, other.userBubble),
      onUserBubble: mix(onUserBubble, other.onUserBubble),
      assistantBubble: mix(assistantBubble, other.assistantBubble),
      onAssistantBubble: mix(onAssistantBubble, other.onAssistantBubble),
      codeBackground: mix(codeBackground, other.codeBackground),
      onCodeBackground: mix(onCodeBackground, other.onCodeBackground),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      accent: mix(accent, other.accent),
      mutedText: mix(mutedText, other.mutedText),
      border: mix(border, other.border),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
    );
  }
}
