import 'package:dio/dio.dart';

import 'package:ai_buddy/core/utils/app_logger.dart';

/// Debug-only request logging: method, URL, status and duration.
///
/// Bodies and headers are deliberately not logged, because they contain
/// passwords, tokens and private chat content.
class LoggingInterceptor extends Interceptor {
  static const String _startKey = '_requestStartMs';
  static const String _tag = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    AppLogger.debug('→ ${options.method} ${options.uri}', tag: _tag);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    AppLogger.debug(
      '← ${response.statusCode} ${options.method} ${options.uri} '
      '(${_elapsedMs(options)} ms)',
      tag: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode?.toString() ?? err.type.name;
    AppLogger.debug(
      '✕ $status ${options.method} ${options.uri} (${_elapsedMs(options)} ms)',
      tag: _tag,
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[_startKey];
    if (start is! int) return 0;
    return DateTime.now().millisecondsSinceEpoch - start;
  }
}
