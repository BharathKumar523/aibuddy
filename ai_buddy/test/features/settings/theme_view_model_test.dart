import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/storage/preferences_service.dart';
import 'package:ai_buddy/core/storage/storage_providers.dart';
import 'package:ai_buddy/features/settings/view_models/theme_view_model.dart';

void main() {
  ProviderContainer makeContainer(PreferencesService prefs) {
    final container = ProviderContainer(
      overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('defaults to system when nothing is stored', () {
    final container = makeContainer(InMemoryPreferencesService());

    expect(container.read(themeViewModelProvider), ThemeMode.system);
  });

  test('restores the stored theme mode', () {
    final container = makeContainer(
      InMemoryPreferencesService({PreferenceKeys.themeMode: 'dark'}),
    );

    expect(container.read(themeViewModelProvider), ThemeMode.dark);
  });

  test('ignores an unknown stored value', () {
    final container = makeContainer(
      InMemoryPreferencesService({PreferenceKeys.themeMode: 'purple'}),
    );

    expect(container.read(themeViewModelProvider), ThemeMode.system);
  });

  test('setThemeMode updates state and persists the choice', () async {
    final prefs = InMemoryPreferencesService();
    final container = makeContainer(prefs);

    await container
        .read(themeViewModelProvider.notifier)
        .setThemeMode(ThemeMode.light);

    expect(container.read(themeViewModelProvider), ThemeMode.light);
    expect(prefs.getString(PreferenceKeys.themeMode), 'light');
  });
}
