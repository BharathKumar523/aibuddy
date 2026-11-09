import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';

enum SnackbarType { info, success, error }

/// One-line feedback messages ("Copied", "Couldn't rename chat").
///
/// Called from Views when they react to ViewModel state. ViewModels never
/// touch `BuildContext`.
abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
  }) {
    final colors = context.colors;
    final palette = context.palette;

    final (Color background, Color foreground, IconData icon) = switch (type) {
      SnackbarType.info => (
          colors.inverseSurface,
          colors.onInverseSurface,
          Icons.info_outline_rounded,
        ),
      SnackbarType.success => (
          palette.success,
          Colors.white,
          Icons.check_circle_outline_rounded,
        ),
      SnackbarType.error => (
          colors.error,
          colors.onError,
          Icons.error_outline_rounded,
        ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Row(
            children: <Widget>[
              Icon(icon, color: foreground, size: 20),
              Gap.w12,
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
        ),
      );
  }
}
