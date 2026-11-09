import 'package:flutter/widgets.dart';

/// 4-pt spacing scale. Use these instead of literal numbers in padding/gaps.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal page padding.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);

  /// Max content width on tablets/landscape, so text lines stay readable.
  static const double maxContentWidth = 720;
}

/// Vertical and horizontal gaps for Rows/Columns.
abstract final class Gap {
  static const SizedBox h4 = SizedBox(height: AppSpacing.xs);
  static const SizedBox h8 = SizedBox(height: AppSpacing.sm);
  static const SizedBox h12 = SizedBox(height: AppSpacing.md);
  static const SizedBox h16 = SizedBox(height: AppSpacing.lg);
  static const SizedBox h24 = SizedBox(height: AppSpacing.xl);
  static const SizedBox h32 = SizedBox(height: AppSpacing.xxl);
  static const SizedBox h48 = SizedBox(height: AppSpacing.xxxl);

  static const SizedBox w4 = SizedBox(width: AppSpacing.xs);
  static const SizedBox w8 = SizedBox(width: AppSpacing.sm);
  static const SizedBox w12 = SizedBox(width: AppSpacing.md);
  static const SizedBox w16 = SizedBox(width: AppSpacing.lg);
}
