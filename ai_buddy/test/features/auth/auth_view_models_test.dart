import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';
import 'package:ai_buddy/features/auth/view_models/auth_form_state.dart';
import 'package:ai_buddy/features/auth/view_models/login_view_model.dart';
import 'package:ai_buddy/features/auth/view_models/register_view_model.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() async {
    repository = signedOutRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      retry: (retryCount, error) => null,
    );
    // The session is always resolved before the auth screens appear.
    await container.read(sessionViewModelProvider.future);
    // The form ViewModels are autoDispose; keep them alive during a test.
    container
      ..listen(loginViewModelProvider, (_, _) {})
      ..listen(registerViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  void stubLogin(Future<dynamic> Function(Invocation) answer) {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((invocation) async => await answer(invocation));
  }

  void stubRegister(Future<dynamic> Function(Invocation) answer) {
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((invocation) async => await answer(invocation));
  }

  group('LoginViewModel', () {
    LoginViewModel vm() => container.read(loginViewModelProvider.notifier);
    AuthFormState form() => container.read(loginViewModelProvider);

    test('signs in with a normalised email and authenticates the session', () async {
      stubLogin((_) async => testUser);

      await vm().submit(email: '  ADA@Example.com ', password: 'secret123');

      verify(
        () => repository.login(email: 'ada@example.com', password: 'secret123'),
      ).called(1);
      expect(container.read(currentUserProvider), testUser);
    });

    test('shows a spinner while the request is in flight', () async {
      final completer = Completer<dynamic>();
      stubLogin((_) => completer.future);

      final pending = vm().submit(email: 'ada@example.com', password: 'x');
      expect(form().isSubmitting, isTrue);

      completer.complete(testUser);
      await pending;
    });

    test('ignores a second submit while the first is running', () async {
      final completer = Completer<dynamic>();
      stubLogin((_) => completer.future);

      final first = vm().submit(email: 'ada@example.com', password: 'x');
      await vm().submit(email: 'ada@example.com', password: 'x');
      completer.complete(testUser);
      await first;

      verify(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).called(1);
    });

    test('shows wrong credentials in the banner and stays signed out', () async {
      stubLogin(
        (_) async => throw const UnauthorizedException(
          message: 'Invalid email or password.',
          code: 'INVALID_CREDENTIALS',
        ),
      );

      await vm().submit(email: 'ada@example.com', password: 'wrong');

      expect(form().isSubmitting, isFalse);
      expect(form().errorMessage, 'Invalid email or password.');
      expect(container.read(currentUserProvider), isNull);
    });

    test('shows network problems in the banner', () async {
      stubLogin((_) async => throw const NetworkException());

      await vm().submit(email: 'ada@example.com', password: 'x');

      expect(form().errorMessage, const NetworkException().message);
    });

    test('maps server field errors to fields and clears them on edit', () async {
      stubLogin(
        (_) async => throw const ValidationException(
          fieldErrors: {'email': 'Enter a valid email address.'},
        ),
      );

      await vm().submit(email: 'bad@x', password: 'x');
      expect(form().fieldErrors, {'email': 'Enter a valid email address.'});

      vm().clearFieldError('email');
      expect(form().fieldErrors, isEmpty);
    });
  });

  group('RegisterViewModel', () {
    RegisterViewModel vm() => container.read(registerViewModelProvider.notifier);
    AuthFormState form() => container.read(registerViewModelProvider);

    test('creates the account with trimmed input and authenticates', () async {
      stubRegister((_) async => testUser);

      await vm().submit(
        name: '  Ada Lovelace ',
        email: ' Ada@Example.com',
        password: 'secret123',
      );

      verify(
        () => repository.register(
          name: 'Ada Lovelace',
          email: 'ada@example.com',
          password: 'secret123',
        ),
      ).called(1);
      expect(container.read(currentUserProvider), testUser);
    });

    test('shows a taken email under the email field', () async {
      stubRegister(
        (_) async => throw const ConflictException(
          message: 'An account with this email already exists.',
          code: 'EMAIL_TAKEN',
        ),
      );

      await vm().submit(name: 'Ada', email: 'ada@example.com', password: 'secret123');

      expect(form().fieldErrors, {
        'email': 'An account with this email already exists.',
      });
      expect(form().errorMessage, isNull);
      expect(form().isSubmitting, isFalse);
    });

    test('shows rate limiting in the banner', () async {
      stubRegister((_) async => throw const RateLimitException(message: 'Slow down'));

      await vm().submit(name: 'Ada', email: 'ada@example.com', password: 'secret123');

      expect(form().errorMessage, 'Slow down');
    });
  });
}
