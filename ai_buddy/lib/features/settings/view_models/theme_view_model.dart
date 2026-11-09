import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/storage/preferences_service.dart';
import 'package:ai_buddy/core/storage/storage_providers.dart';

/// Owns the selected theme mode and persists it.
///
/// The initial value is read synchronously from the preload cache, so the
/// first frame already uses the saved theme.
final themeViewModelProvider = NotifierProvider<ThemeViewModel, ThemeMode>(
  ThemeViewModel.new,
  name: 'themeViewModelProvider',
);

class ThemeViewModel extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref
        .watch(preferencesServiceProvider)
        .getString(PreferenceKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await ref
        .read(preferencesServiceProvider)
        .setString(PreferenceKeys.themeMode, mode.name);
  }
}
