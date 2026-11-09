import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, text }

/// The app's one button component.
///
/// While [isLoading] is true it shows a spinner and ignores taps, which
/// prevents double submissions on forms.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// Stretch to the parent's full width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final spinnerColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final Widget content = isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spinnerColor,
            ),
          )
        : _Label(label: label, icon: icon);

    final Widget button = switch (variant) {
      AppButtonVariant.primary =>
        FilledButton(onPressed: effectiveOnPressed, child: content),
      AppButtonVariant.secondary =>
        OutlinedButton(onPressed: effectiveOnPressed, child: content),
      AppButtonVariant.text =>
        TextButton(onPressed: effectiveOnPressed, child: content),
    };

    return Semantics(
      button: true,
      label: isLoading ? '$label, loading' : null,
      excludeSemantics: isLoading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    if (iconData == null) {
      return Text(label, overflow: TextOverflow.ellipsis);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(iconData, size: 18),
        Gap.w8,
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
