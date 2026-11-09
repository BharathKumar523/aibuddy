import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/storage/preferences_service.dart';
import 'package:ai_buddy/core/storage/token_storage.dart';

/// Secure JWT storage. Overridden with a fake in tests.
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
  name: 'tokenStorageProvider',
);

/// Preferences must be loaded asynchronously before `runApp`, so this
/// provider is always overridden in `main.dart` (and in tests).
final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => throw UnimplementedError(
    'preferencesServiceProvider must be overridden in ProviderScope.',
  ),
  name: 'preferencesServiceProvider',
);
