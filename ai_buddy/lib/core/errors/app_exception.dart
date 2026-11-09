/// The single error type that leaves the data layer.
///
/// Repositories convert every low-level failure (Dio, JSON parsing, storage)
/// into one of these, so ViewModels and Views only ever deal with
/// [AppException] and can `switch` over it exhaustively.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode});

  /// Human-readable message, safe to show in the UI.
  final String message;

  /// Machine-readable code, usually from the backend error envelope
  /// (e.g. `EMAIL_TAKEN`, `VALIDATION_ERROR`).
  final String? code;

  /// HTTP status code, when the error came from a response.
  final int? statusCode;

  /// Whether retrying the same action could reasonably succeed.
  bool get isRetryable => false;

  @override
  String toString() =>
      '$runtimeType(code: $code, statusCode: $statusCode, message: $message)';
}

/// No connection, DNS failure, refused connection, bad certificate.
final class NetworkException extends AppException {
  const NetworkException({String? message})
      : super(
          message ??
              'Unable to reach the server. Check your connection and try again.',
          code: 'NETWORK_ERROR',
        );

  @override
  bool get isRetryable => true;
}

/// Connect/send/receive timeout.
final class RequestTimeoutException extends AppException {
  const RequestTimeoutException({String? message})
      : super(
          message ?? 'The request took too long. Please try again.',
          code: 'TIMEOUT',
        );

  @override
  bool get isRetryable => true;
}

/// The request was cancelled on purpose (e.g. user stopped a stream).
final class CancelledException extends AppException {
  const CancelledException({String? message})
      : super(message ?? 'The request was cancelled.', code: 'CANCELLED');
}

/// 400 / 422 with optional per-field messages.
final class ValidationException extends AppException {
  const ValidationException({
    String? message,
    this.fieldErrors = const <String, String>{},
    String? code,
    int? statusCode,
  }) : super(
          message ?? 'Please check the highlighted fields.',
          code: code ?? 'VALIDATION_ERROR',
          statusCode: statusCode ?? 400,
        );

  /// Field name → error message, e.g. `{'email': 'Email is invalid'}`.
  final Map<String, String> fieldErrors;
}

/// 401: missing, invalid or expired token, or wrong credentials on login.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({String? message, String? code})
      : super(
          message ?? 'Your session has expired. Please sign in again.',
          code: code ?? 'UNAUTHORIZED',
          statusCode: 401,
        );
}

/// 403.
final class ForbiddenException extends AppException {
  const ForbiddenException({String? message, String? code})
      : super(
          message ?? 'You do not have permission to do that.',
          code: code ?? 'FORBIDDEN',
          statusCode: 403,
        );
}

/// 404. Also returned for resources owned by another user.
final class NotFoundException extends AppException {
  const NotFoundException({String? message, String? code})
      : super(
          message ?? 'The requested item could not be found.',
          code: code ?? 'NOT_FOUND',
          statusCode: 404,
        );
}

/// 409: duplicate email, duplicate submission, conversation busy.
final class ConflictException extends AppException {
  const ConflictException({String? message, String? code})
      : super(
          message ?? 'This action conflicts with the current state.',
          code: code ?? 'CONFLICT',
          statusCode: 409,
        );
}

/// 429.
final class RateLimitException extends AppException {
  const RateLimitException({String? message, String? code, this.retryAfter})
      : super(
          message ?? 'Too many requests. Please wait a moment and try again.',
          code: code ?? 'RATE_LIMITED',
          statusCode: 429,
        );

  /// Parsed from the `Retry-After` header when the server sends it.
  final Duration? retryAfter;

  @override
  bool get isRetryable => true;
}

/// 5xx, including AI provider failures surfaced as 502.
final class ServerException extends AppException {
  const ServerException({String? message, String? code, int? statusCode})
      : super(
          message ?? 'Something went wrong on our side. Please try again.',
          code: code ?? 'SERVER_ERROR',
          statusCode: statusCode ?? 500,
        );

  @override
  bool get isRetryable => true;
}

/// Anything we could not classify (parsing errors, unexpected statuses).
final class UnknownException extends AppException {
  const UnknownException({String? message, this.cause, int? statusCode})
      : super(
          message ?? 'Something unexpected happened. Please try again.',
          code: 'UNKNOWN_ERROR',
          statusCode: statusCode,
        );

  /// The original error, kept for logging. Never shown to users.
  final Object? cause;
}
