import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/features/settings/view_models/theme_view_model.dart';

/// System / Light / Dark switch bound to [ThemeViewModel].
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeViewModelProvider);

    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: <ThemeMode>{mode},
      onSelectionChanged: (selection) {
        unawaited(
          ref.read(themeViewModelProvider.notifier).setThemeMode(
                selection.first,
              ),
        );
      },
    );
  }
}
