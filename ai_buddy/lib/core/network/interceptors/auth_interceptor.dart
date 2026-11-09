import 'package:dio/dio.dart';

import 'package:ai_buddy/core/storage/token_storage.dart';
import 'package:ai_buddy/core/utils/app_logger.dart';

/// Adds `Authorization: Bearer <jwt>` to requests and reacts to 401s.
///
/// Requests can opt out with `Options(extra: {AuthInterceptor.skipAuthKey: true})`.
/// Login and register do this, so a wrong password (also a 401) doesn't
/// trigger the "session expired" sign-out.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required void Function() onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _onUnauthorized = onUnauthorized;

  static const String skipAuthKey = 'skipAuth';
  static const String _header = 'Authorization';

  final TokenStorage _tokenStorage;
  final void Function() _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] != true) {
      try {
        final token = await _tokenStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers[_header] = 'Bearer $token';
        }
      } on Object catch (e, st) {
        // Continue without a token; the server will answer 401 if needed.
        AppLogger.error('Could not read access token', error: e, stackTrace: st);
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final sentToken = err.requestOptions.headers.containsKey(_header);
    if (err.response?.statusCode == 401 && sentToken) {
      _onUnauthorized();
    }
    handler.next(err);
  }
}
