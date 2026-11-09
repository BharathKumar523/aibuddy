import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/session/session_state.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/core/session/unauthorized_signal.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';

import '../../helpers/fakes.dart';

void main() {
  ProviderContainer makeContainer(MockAuthRepository repository) {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      retry: (retryCount, error) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  group('restoring the session', () {
    test('no stored token → unauthenticated, without calling the API', () async {
      final repository = signedOutRepository();
      final container = makeContainer(repository);

      final state = await container.read(sessionViewModelProvider.future);

      expect(state, const SessionState.unauthenticated());
      verifyNever(repository.currentUser);
    });

    test('stored token and /me succeeds → authenticated with the user', () async {
      final container = makeContainer(signedInRepository());

      final state = await container.read(sessionViewModelProvider.future);

      expect(state, SessionState.authenticated(testUser));
      expect(container.read(currentUserProvider), testUser);
    });

    test('stored token rejected (401) → token deleted, unauthenticated', () async {
      final repository = signedInRepository();
      when(repository.currentUser).thenThrow(const UnauthorizedException());
      final container = makeContainer(repository);

      final state = await container.read(sessionViewModelProvider.future);

      expect(state, const SessionState.unauthenticated());
      verify(repository.logout).called(1);
    });

    test('server unreachable → error state, user NOT signed out', () async {
      final repository = signedInRepository();
      when(repository.currentUser).thenThrow(const NetworkException());
      final container = makeContainer(repository);

      await expectLater(
        container.read(sessionViewModelProvider.future),
        throwsA(anything),
      );

      final session = container.read(sessionViewModelProvider);
      expect(session.hasError, isTrue);
      expect(session.error, isA<NetworkException>());
      verifyNever(repository.logout);
    });

    test('retry restores the session once the server is back', () async {
      final repository = signedInRepository();
      when(repository.currentUser).thenThrow(const NetworkException());
      final container = makeContainer(repository);
      await expectLater(
        container.read(sessionViewModelProvider.future),
        throwsA(anything),
      );

      when(repository.currentUser).thenAnswer((_) async => testUser);
      container.read(sessionViewModelProvider.notifier).retry();

      expect(
        await container.read(sessionViewModelProvider.future),
        SessionState.authenticated(testUser),
      );
    });

    test('unreadable keystore → unauthenticated and cleared', () async {
      final repository = signedOutRepository();
      when(repository.hasStoredSession).thenThrow(StateError('keystore broken'));
      final container = makeContainer(repository);

      final state = await container.read(sessionViewModelProvider.future);

      expect(state, const SessionState.unauthenticated());
      verify(repository.logout).called(1);
    });
  });

  group('during a session', () {
    test('setAuthenticated switches to the signed-in user', () async {
      final container = makeContainer(signedOutRepository());
      await container.read(sessionViewModelProvider.future);

      container.read(sessionViewModelProvider.notifier).setAuthenticated(testUser);

      expect(container.read(currentUserProvider), testUser);
    });

    test('signOut deletes the token and unauthenticates', () async {
      final repository = signedInRepository();
      final container = makeContainer(repository);
      await container.read(sessionViewModelProvider.future);

      await container.read(sessionViewModelProvider.notifier).signOut();

      verify(repository.logout).called(1);
      expect(
        container.read(sessionViewModelProvider).value,
        const SessionState.unauthenticated(),
      );
    });

    test('a 401 signal from the network layer signs the user out', () async {
      final repository = signedInRepository();
      final container = makeContainer(repository);
      await container.read(sessionViewModelProvider.future);

      container.read(unauthorizedSignalProvider).notify();
      // Let the stream deliver and signOut complete.
      await pumpEventQueue();

      verify(repository.logout).called(1);
      expect(
        container.read(sessionViewModelProvider).value,
        const SessionState.unauthenticated(),
      );
    });

    test('a 401 signal while signed out is ignored', () async {
      final repository = signedOutRepository();
      final container = makeContainer(repository);
      await container.read(sessionViewModelProvider.future);

      container.read(unauthorizedSignalProvider).notify();
      await pumpEventQueue();

      verifyNever(repository.logout);
    });
  });

  test('handleUnauthorized during restore is ignored (build handles 401)', () async {
    final repository = signedInRepository();
    final pending = Completer<void>();
    when(repository.currentUser).thenAnswer((_) async {
      await pending.future;
      return testUser;
    });
    final container = makeContainer(repository);
    final future = container.read(sessionViewModelProvider.future);

    await container.read(sessionViewModelProvider.notifier).handleUnauthorized();
    pending.complete();

    expect(await future, SessionState.authenticated(testUser));
    verifyNever(repository.logout);
  });
}
