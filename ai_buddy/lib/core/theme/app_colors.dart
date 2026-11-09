import 'package:flutter/material.dart';

/// Raw color tokens for one brightness.
///
/// Widgets never reference these directly. They read `ColorScheme` or the
/// `AppPalette` theme extension, so light and dark mode switch automatically.
class AppColorTokens {
  const AppColorTokens({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.onError,
    required this.success,
    required this.warning,
    required this.userBubble,
    required this.onUserBubble,
    required this.assistantBubble,
    required this.onAssistantBubble,
    required this.codeBackground,
    required this.onCodeBackground,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color onError;
  final Color success;
  final Color warning;
  final Color userBubble;
  final Color onUserBubble;
  final Color assistantBubble;
  final Color onAssistantBubble;
  final Color codeBackground;
  final Color onCodeBackground;
}

/// Brand palette: deep teal on warm neutrals, with an amber accent.
abstract final class AppColors {
  static const AppColorTokens light = AppColorTokens(
    brightness: Brightness.light,
    primary: Color(0xFF0F766E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDEFEA),
    onPrimaryContainer: Color(0xFF053B37),
    accent: Color(0xFFD98A0B),
    background: Color(0xFFF7F7F4),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0F0EC),
    surfaceStrong: Color(0xFFE6E6E0),
    border: Color(0xFFE2E2DC),
    textPrimary: Color(0xFF1B1C1A),
    textSecondary: Color(0xFF686B66),
    error: Color(0xFFC93A3A),
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF2E8B57),
    warning: Color(0xFFC98A00),
    userBubble: Color(0xFF0F766E),
    onUserBubble: Color(0xFFFFFFFF),
    assistantBubble: Color(0xFFF0F0EC),
    onAssistantBubble: Color(0xFF1B1C1A),
    codeBackground: Color(0xFF1D2321),
    onCodeBackground: Color(0xFFE4E8E6),
  );

  static const AppColorTokens dark = AppColorTokens(
    brightness: Brightness.dark,
    primary: Color(0xFF3CCFBC),
    onPrimary: Color(0xFF032B27),
    primaryContainer: Color(0xFF14504A),
    onPrimaryContainer: Color(0xFFCDEFEA),
    accent: Color(0xFFF2B544),
    background: Color(0xFF111413),
    surface: Color(0xFF181C1B),
    surfaceMuted: Color(0xFF212625),
    surfaceStrong: Color(0xFF2B3130),
    border: Color(0xFF2C3231),
    textPrimary: Color(0xFFE9ECEA),
    textSecondary: Color(0xFF9AA19E),
    error: Color(0xFFFF7A72),
    onError: Color(0xFF3A0905),
    success: Color(0xFF5BC98A),
    warning: Color(0xFFF2B544),
    userBubble: Color(0xFF14504A),
    onUserBubble: Color(0xFFE9F7F5),
    assistantBubble: Color(0xFF1F2423),
    onAssistantBubble: Color(0xFFE9ECEA),
    codeBackground: Color(0xFF0B0E0D),
    onCodeBackground: Color(0xFFDDE3E0),
  );
}
