import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/theme_extensions.dart';

/// The AI Buddy mark: a rounded tile with a sparkle, in brand colors.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'AI Buddy logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.3),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[colors.primary, colors.primaryContainer],
          ),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          size: size * 0.5,
          color: colors.onPrimary,
        ),
      ),
    );
  }
}
