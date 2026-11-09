import 'package:dio/dio.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/network/api_error.dart';
import 'package:ai_buddy/core/utils/app_logger.dart';

/// Converts any thrown object into an [AppException].
///
/// This is the only place that knows about Dio error types and the backend
/// error envelope. Everything above the data layer uses [AppException].
abstract final class ErrorMapper {
  static AppException map(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    if (error is DioException) return fromDio(error);
    
    AppLogger.error('Unmapped error', error: error, stackTrace: stackTrace);
    return UnknownException(cause: error);
  }

  static AppException fromDio(DioException e) {
    final inner = e.error;
    if (inner is AppException) return inner;

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        const RequestTimeoutException(),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate =>
        const NetworkException(),
      DioExceptionType.cancel => const CancelledException(),
      DioExceptionType.badResponse => fromResponse(
          statusCode: e.response?.statusCode,
          data: e.response?.data,
          headers: e.response?.headers,
        ),
      DioExceptionType.unknown => UnknownException(cause: inner ?? e),
    };
  }

  /// Maps an HTTP status code and response body to an [AppException].
  static AppException fromResponse({
    required int? statusCode,
    required Object? data,
    Headers? headers,
  }) {
    final apiError = _parseApiError(data);
    final message = apiError?.message;
    final code = apiError?.code;

    if (statusCode == null) {
      return UnknownException(message: message, cause: data);
    }

    return switch (statusCode) {
      400 || 422 => ValidationException(
          message: message,
          code: code,
          statusCode: statusCode,
          fieldErrors: _fieldErrors(apiError),
        ),
      401 => UnauthorizedException(message: message, code: code),
      403 => ForbiddenException(message: message, code: code),
      404 => NotFoundException(message: message, code: code),
      409 => ConflictException(message: message, code: code),
      429 => RateLimitException(
          message: message,
          code: code,
          retryAfter: _retryAfter(headers),
        ),
      >= 500 => ServerException(
          message: message,
          code: code,
          statusCode: statusCode,
        ),
      _ => UnknownException(message: message, statusCode: statusCode),
    };
  }

  static ApiError? _parseApiError(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final error = data['error'];
    if (error is! Map<String, dynamic>) return null;
    try {
      return ApiError.fromJson(error);
    } on Object catch (e, st) {
      AppLogger.error('Malformed error envelope', error: e, stackTrace: st);
      return null;
    }
  }

  static Map<String, String> _fieldErrors(ApiError? apiError) {
    if (apiError == null) return const <String, String>{};
    return <String, String>{
      for (final detail in apiError.details)
        if (detail.field != null) detail.field!: detail.message,
    };
  }

  static Duration? _retryAfter(Headers? headers) {
    final raw = headers?.value('retry-after');
    final seconds = raw == null ? null : int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
