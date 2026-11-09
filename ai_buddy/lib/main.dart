import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/app.dart';
import 'package:ai_buddy/core/config/env.dart';
import 'package:ai_buddy/core/errors/app_provider_observer.dart';
import 'package:ai_buddy/core/errors/global_error_handler.dart';
import 'package:ai_buddy/core/storage/preferences_service.dart';
import 'package:ai_buddy/core/storage/storage_providers.dart';
import 'package:ai_buddy/core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalErrorHandler.install();

  AppLogger.info('Starting AI Buddy (${Env.appEnv}) → ${Env.apiBaseUrl}');

  final preferences = await _loadPreferences();

  runApp(
    ProviderScope(
      observers: <ProviderObserver>[AppProviderObserver()],
      // Riverpod 3 retries failing providers automatically. This app shows
      // errors with an explicit "Try again" instead, so retries are off.
      retry: (retryCount, error) => null,
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferences),
      ],
      child: const AiBuddyApp(),
    ),
  );
}

/// Loads preferences before the first frame so the saved theme applies
/// immediately. Falls back to in-memory storage rather than failing launch.
Future<PreferencesService> _loadPreferences() async {
  try {
    return await SharedPreferencesService.create();
  } on Object catch (e, st) {
    AppLogger.error('Preferences unavailable; using defaults',
        error: e, stackTrace: st);
    return InMemoryPreferencesService();
  }
}
