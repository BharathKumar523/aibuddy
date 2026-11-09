import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Thin logging facade so the rest of the app never calls `print`.
///
/// Debug/info logs are dropped in release builds; errors are always logged.
/// Swap the implementation for Crashlytics/Sentry later without touching
/// call sites.
abstract final class AppLogger {
  static const String _defaultTag = 'AiBuddy';

  static void debug(String message, {String tag = _defaultTag}) {
    if (kDebugMode) developer.log(message, name: tag, level: 500);
  }

  static void info(String message, {String tag = _defaultTag}) {
    if (kDebugMode) developer.log(message, name: tag, level: 800);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = _defaultTag,
  }) {
    developer.log(
      message,
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
