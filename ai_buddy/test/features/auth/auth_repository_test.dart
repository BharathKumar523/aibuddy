import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/network/api_client.dart';
import 'package:ai_buddy/core/network/interceptors/auth_interceptor.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/stub_http_adapter.dart';

void main() {
  const userJson = <String, dynamic>{
    'id': '65a1b2c3d4e5f6a7b8c9d0e1',
    'name': 'Ada Lovelace',
    'email': 'ada@example.com',
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
  };

  const authData = <String, dynamic>{
    'user': userJson,
    'accessToken': 'header.payload.signature',
    'tokenType': 'Bearer',
    'expiresIn': 604800,
  };

  late FakeTokenStorage storage;

  (AuthRepositoryImpl, StubHttpAdapter) build(Map<String, (int, Object?)> routes) {
    final adapter = StubHttpAdapter(routes);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(tokenStorage: storage, onUnauthorized: () {}),
      );
    return (AuthRepositoryImpl(api: ApiClient(dio), tokenStorage: storage), adapter);
  }

  setUp(() => storage = FakeTokenStorage());

  test('login sends credentials without a token, stores the new token', () async {
    storage.token = 'old-token';
    final (repository, adapter) = build({
      'POST /auth/login': (200, {'success': true, 'data': authData}),
    });

    final user = await repository.login(email: 'ada@example.com', password: 'secret123');

    expect(user.email, 'ada@example.com');
    expect(user.createdAt, DateTime.utc(2026));
    expect(storage.token, 'header.payload.signature');

    final request = adapter.requests.single;
    expect(request.data, {'email': 'ada@example.com', 'password': 'secret123'});
    expect(request.headers.containsKey('Authorization'), isFalse);
  });

  test('register sends name, email and password and stores the token', () async {
    final (repository, adapter) = build({
      'POST /auth/register': (201, {'success': true, 'data': authData}),
    });

    final user = await repository.register(
      name: 'Ada Lovelace',
      email: 'ada@example.com',
      password: 'secret123',
    );

    expect(user.name, 'Ada Lovelace');
    expect(storage.token, 'header.payload.signature');
    expect(adapter.requests.single.data, {
      'name': 'Ada Lovelace',
      'email': 'ada@example.com',
      'password': 'secret123',
    });
  });

  test('a failed login does not store anything', () async {
    final (repository, _) = build({
      'POST /auth/login': (
        401,
        {
          'success': false,
          'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Invalid email or password.'},
        },
      ),
    });

    await expectLater(
      repository.login(email: 'ada@example.com', password: 'nope'),
      throwsA(
        isA<UnauthorizedException>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS'),
      ),
    );
    expect(storage.token, isNull);
  });

  test('EMAIL_TAKEN surfaces as ConflictException', () async {
    final (repository, _) = build({
      'POST /auth/register': (
        409,
        {
          'success': false,
          'error': {'code': 'EMAIL_TAKEN', 'message': 'An account with this email already exists.'},
        },
      ),
    });

    await expectLater(
      repository.register(name: 'Ada', email: 'ada@example.com', password: 'secret123'),
      throwsA(isA<ConflictException>().having((e) => e.code, 'code', 'EMAIL_TAKEN')),
    );
  });

  test('currentUser sends the stored token and parses the user', () async {
    storage.token = 'stored-token';
    final (repository, adapter) = build({
      'GET /auth/me': (200, {
        'success': true,
        'data': {'user': userJson},
      }),
    });

    final user = await repository.currentUser();

    expect(user.id, '65a1b2c3d4e5f6a7b8c9d0e1');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer stored-token');
  });

  test('hasStoredSession and logout use token storage', () async {
    final (repository, _) = build({});

    expect(await repository.hasStoredSession(), isFalse);
    storage.token = 'abc';
    expect(await repository.hasStoredSession(), isTrue);

    await repository.logout();
    expect(storage.token, isNull);
    expect(await repository.hasStoredSession(), isFalse);
  });
}
