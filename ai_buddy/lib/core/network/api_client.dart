import 'package:dio/dio.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/network/api_response.dart';
import 'package:ai_buddy/core/network/interceptors/auth_interceptor.dart';
import 'package:ai_buddy/core/utils/app_logger.dart';

/// Typed REST client on top of Dio.
///
/// It unwraps the `{ success, data, meta }` envelope, parses `data` with the
/// caller's parser, and converts every failure into an `AppException`.
/// Repositories depend on this class, never on Dio directly.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    required JsonParser<T> parser,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) {
    return _send(
      () => _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _options(authenticated),
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    required JsonParser<T> parser,
    Object? data,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) {
    return _send(
      () => _dio.post<Object?>(
        path,
        data: data,
        cancelToken: cancelToken,
        options: _options(authenticated),
      ),
      parser,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    required JsonParser<T> parser,
    Object? data,
    CancelToken? cancelToken,
    bool authenticated = true,
  }) {
    return _send(
      () => _dio.patch<Object?>(
        path,
        data: data,
        cancelToken: cancelToken,
        options: _options(authenticated),
      ),
      parser,
    );
  }

  /// DELETE endpoints return `204 No Content`, so there is nothing to parse.
  Future<void> delete(
    String path, {
    CancelToken? cancelToken,
    bool authenticated = true,
  }) async {
    await _send<void>(
      () => _dio.delete<Object?>(
        path,
        cancelToken: cancelToken,
        options: _options(authenticated),
      ),
      (_) {},
    );
  }

  Options _options(bool authenticated) =>
      Options(extra: <String, dynamic>{AuthInterceptor.skipAuthKey: !authenticated});

  Future<ApiResponse<T>> _send<T>(
    Future<Response<Object?>> Function() request,
    JsonParser<T> parser,
  ) async {
    try {
      final response = await request();
      final body = response.data;

      if (response.statusCode == 204 || body == null || body == '') {
        return ApiResponse<T>(data: parser(null));
      }

      if (body is Map<String, dynamic>) {
        if (body['success'] == false) {
          throw ErrorMapper.fromResponse(
            statusCode: response.statusCode,
            data: body,
            headers: response.headers,
          );
        }
        final meta = body['meta'];
        return ApiResponse<T>(
          data: parser(body['data']),
          meta: meta is Map<String, dynamic> ? meta : const <String, dynamic>{},
        );
      }

      throw const UnknownException(
        message: 'The server sent a response the app does not understand.',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } on Object catch (e, st) {
      // Parser failures (FormatException, TypeError from fromJson, ...).
      AppLogger.error('Failed to parse response', error: e, stackTrace: st);
      throw UnknownException(
        message: 'The server sent a response the app does not understand.',
        cause: e,
      );
    }
  }
}
