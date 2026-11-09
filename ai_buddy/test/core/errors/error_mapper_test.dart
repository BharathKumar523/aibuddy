import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/errors/error_mapper.dart';

void main() {
  final options = RequestOptions(path: '/test');

  DioException typed(DioExceptionType type) =>
      DioException(requestOptions: options, type: type);

  DioException badResponse(
    int status,
    Object? data, {
    Map<String, List<String>> headers = const {},
  }) {
    return DioException.badResponse(
      statusCode: status,
      requestOptions: options,
      response: Response<Object?>(
        requestOptions: options,
        statusCode: status,
        data: data,
        headers: Headers.fromMap(headers),
      ),
    );
  }

  Map<String, dynamic> envelope(
    String code,
    String message, [
    List<Map<String, dynamic>> details = const [],
  ]) {
    return <String, dynamic>{
      'success': false,
      'error': <String, dynamic>{
        'code': code,
        'message': message,
        'details': details,
      },
    };
  }

  group('transport errors', () {
    test('timeouts map to RequestTimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(ErrorMapper.fromDio(typed(type)), isA<RequestTimeoutException>());
      }
    });

    test('connection errors map to NetworkException', () {
      final error = ErrorMapper.fromDio(typed(DioExceptionType.connectionError));
      expect(error, isA<NetworkException>());
      expect(error.isRetryable, isTrue);
    });

    test('cancellation maps to CancelledException', () {
      expect(
        ErrorMapper.fromDio(typed(DioExceptionType.cancel)),
        isA<CancelledException>(),
      );
    });
  });

  group('HTTP errors', () {
    test('400 keeps the server message and per-field errors', () {
      final error = ErrorMapper.fromDio(
        badResponse(
          400,
          envelope('VALIDATION_ERROR', 'Invalid input', [
            {'field': 'email', 'message': 'Email is invalid'},
            {'message': 'No field attached'},
          ]),
        ),
      );

      expect(error, isA<ValidationException>());
      final validation = error as ValidationException;
      expect(validation.message, 'Invalid input');
      expect(validation.fieldErrors, {'email': 'Email is invalid'});
    });

    test('401 maps to UnauthorizedException', () {
      final error = ErrorMapper.fromDio(
        badResponse(401, envelope('UNAUTHORIZED', 'Token expired')),
      );
      expect(error, isA<UnauthorizedException>());
      expect(error.message, 'Token expired');
    });

    test('409 keeps the specific server code', () {
      final error = ErrorMapper.fromDio(
        badResponse(409, envelope('EMAIL_TAKEN', 'Email already registered')),
      );
      expect(error, isA<ConflictException>());
      expect(error.code, 'EMAIL_TAKEN');
    });

    test('429 reads Retry-After', () {
      final error = ErrorMapper.fromDio(
        badResponse(
          429,
          envelope('RATE_LIMITED', 'Slow down'),
          headers: {
            'retry-after': ['30'],
          },
        ),
      );
      expect(error, isA<RateLimitException>());
      expect((error as RateLimitException).retryAfter,
          const Duration(seconds: 30));
    });

    test('5xx without a JSON body falls back to a friendly message', () {
      final error = ErrorMapper.fromDio(badResponse(502, '<html>Bad gateway'));
      expect(error, isA<ServerException>());
      expect(error.statusCode, 502);
      expect(error.message, isNotEmpty);
    });
  });

  test('unknown objects map to UnknownException', () {
    expect(ErrorMapper.map(StateError('boom')), isA<UnknownException>());
  });

  test('AppExceptions pass through unchanged', () {
    const original = NotFoundException();
    expect(ErrorMapper.map(original), same(original));
  });
}
