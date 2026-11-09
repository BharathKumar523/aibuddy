import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/utils/app_logger.dart';

/// Logs every provider that fails while building or updating.
///
/// Registered once on the root `ProviderScope`, so failures inside any
/// ViewModel are visible in the logs even when the UI handles them.
final class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final provider = context.provider;
    AppLogger.error(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
      tag: 'Riverpod',
    );
  }
}
