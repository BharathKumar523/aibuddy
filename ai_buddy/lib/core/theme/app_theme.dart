import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_colors.dart';
import 'package:ai_buddy/core/theme/app_palette.dart';
import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/app_typography.dart';

/// Builds the Material 3 light and dark themes from the color tokens.
abstract final class AppTheme {
  static final ThemeData light = _build(AppColors.light);
  static final ThemeData dark = _build(AppColors.dark);

  static ThemeData _build(AppColorTokens t) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: t.primary,
      brightness: t.brightness,
    ).copyWith(
      primary: t.primary,
      onPrimary: t.onPrimary,
      primaryContainer: t.primaryContainer,
      onPrimaryContainer: t.onPrimaryContainer,
      tertiary: t.accent,
      surface: t.surface,
      onSurface: t.textPrimary,
      onSurfaceVariant: t.textSecondary,
      surfaceContainerLowest: t.background,
      surfaceContainerLow: t.surface,
      surfaceContainer: t.surfaceMuted,
      surfaceContainerHigh: t.surfaceMuted,
      surfaceContainerHighest: t.surfaceStrong,
      outline: t.border,
      outlineVariant: t.border,
      error: t.error,
      onError: t.onError,
    );

    final textTheme = AppTypography.textTheme(t.textPrimary, t.textSecondary);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );

    const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    const buttonMinSize = Size(64, 52);
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

    return ThemeData(
      brightness: t.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.background,
      canvasColor: t.background,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[AppPalette.fromTokens(t)],
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: t.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: t.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: t.primary),
        border: inputBorder(t.border),
        enabledBorder: inputBorder(t.border),
        focusedBorder: inputBorder(t.primary, 1.5),
        errorBorder: inputBorder(t.error),
        focusedErrorBorder: inputBorder(t.error, 1.5),
        disabledBorder: inputBorder(t.border.withValues(alpha: 0.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.primary,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: t.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        iconColor: t.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.primary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}
