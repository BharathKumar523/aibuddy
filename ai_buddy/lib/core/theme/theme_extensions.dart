import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_palette.dart';

/// Short accessors so widgets read `context.colors.primary` instead of
/// `Theme.of(context).colorScheme.primary`.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
