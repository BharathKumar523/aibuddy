import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ai_buddy/core/utils/app_logger.dart';

/// Installs app-wide handlers for errors nobody caught.
///
/// * [FlutterError.onError]: errors thrown during build, layout and paint.
/// * [PlatformDispatcher.onError]: uncaught async errors (futures, streams).
/// * [ErrorWidget.builder]: in release builds, replaces the red error screen
///   with a calm fallback so one broken widget doesn't look like a crash.
///
/// Expected failures (network, validation) never reach here: repositories
/// map them to `AppException` and ViewModels expose them as UI state.
abstract final class GlobalErrorHandler {
  static void install() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.error('Uncaught async error', error: error, stackTrace: stack);
      // true = handled; prevents the engine from treating it as fatal.
      return true;
    };

    if (kReleaseMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) =>
          const _ReleaseErrorWidget();
    }
  }
}

class _ReleaseErrorWidget extends StatelessWidget {
  const _ReleaseErrorWidget();

  @override
  Widget build(BuildContext context) {
    // This can render outside MaterialApp, so it can't rely on Theme or
    // Directionality being available.
    return const ColoredBox(
      color: Color(0x00000000),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Something went wrong while showing this section.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Color(0xFF8A8F8C), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
