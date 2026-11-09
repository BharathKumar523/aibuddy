import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/network/api_client.dart';
import 'package:ai_buddy/core/network/api_response.dart';
import 'package:ai_buddy/core/network/interceptors/auth_interceptor.dart';

import '../../helpers/fakes.dart';

/// Serves canned responses and records the last request, so ApiClient and
/// AuthInterceptor are tested without a server.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object? body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (body == null) {
      // e.g. 204 No Content: no body and no content type.
      return ResponseBody.fromString('', statusCode);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeTokenStorage storage;
  late int unauthorizedCalls;

  (ApiClient, _StubAdapter) build(int status, Object? body) {
    final adapter = _StubAdapter(status, body);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenStorage: storage,
          onUnauthorized: () => unauthorizedCalls++,
        ),
      );
    return (ApiClient(dio), adapter);
  }

  setUp(() {
    storage = FakeTokenStorage(token: 'jwt-123');
    unauthorizedCalls = 0;
  });

  test('unwraps data and meta from the success envelope', () async {
    final (client, _) = build(200, {
      'success': true,
      'data': {'name': 'Ada'},
      'meta': {'hasMore': false},
    });

    final response = await client.get<String>(
      '/thing',
      parser: (json) => asJsonMap(json)['name'] as String,
    );

    expect(response.data, 'Ada');
    expect(response.meta['hasMore'], isFalse);
  });

  test('attaches the bearer token to authenticated requests', () async {
    final (client, adapter) = build(200, {'success': true, 'data': null});

    await client.get<void>('/me', parser: (_) {});

    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer jwt-123');
  });

  test('omits the token when authenticated is false', () async {
    final (client, adapter) = build(200, {'success': true, 'data': null});

    await client.post<void>('/auth/login', authenticated: false, parser: (_) {});

    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });

  test('401 on an authenticated request triggers onUnauthorized', () async {
    final (client, _) = build(401, {
      'success': false,
      'error': {'code': 'UNAUTHORIZED', 'message': 'Token expired'},
    });

    await expectLater(
      client.get<void>('/me', parser: (_) {}),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(unauthorizedCalls, 1);
  });

  test('401 on login does not sign the user out', () async {
    final (client, _) = build(401, {
      'success': false,
      'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Wrong password'},
    });

    await expectLater(
      client.post<void>('/auth/login', authenticated: false, parser: (_) {}),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(unauthorizedCalls, 0);
  });

  test('204 No Content succeeds for delete', () async {
    final (client, _) = build(204, null);

    await expectLater(client.delete('/conversations/1'), completes);
  });

  test('a parser failure becomes UnknownException', () async {
    final (client, _) = build(200, {'success': true, 'data': 'not a map'});

    await expectLater(
      client.get<Map<String, dynamic>>('/thing', parser: asJsonMap),
      throwsA(isA<UnknownException>()),
    );
  });
}
