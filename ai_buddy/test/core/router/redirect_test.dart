import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/router/app_router.dart';
import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/core/session/session_state.dart';

import '../../helpers/fakes.dart';

void main() {
  const loading = AsyncLoading<SessionState>();
  const failed = AsyncError<SessionState>(
    NetworkException(),
    StackTrace.empty,
  );
  final signedIn = AsyncData<SessionState>(SessionState.authenticated(testUser));
  const signedOut = AsyncData<SessionState>(SessionState.unauthenticated());

  group('resolveRedirect', () {
    test('holds every route on splash while the session is unknown', () {
      expect(resolveRedirect(loading, RoutePaths.splash), isNull);
      expect(resolveRedirect(loading, RoutePaths.chat), RoutePaths.splash);
      expect(resolveRedirect(loading, RoutePaths.login), RoutePaths.splash);
    });

    test('stays on splash when restoring failed (offline), so Retry is shown', () {
      expect(resolveRedirect(failed, RoutePaths.splash), isNull);
      expect(resolveRedirect(failed, RoutePaths.chat), RoutePaths.splash);
    });

    test('leaves splash for the right destination', () {
      expect(resolveRedirect(signedIn, RoutePaths.splash), RoutePaths.chat);
      expect(resolveRedirect(signedOut, RoutePaths.splash), RoutePaths.login);
    });

    test('protects private routes from signed-out users', () {
      expect(resolveRedirect(signedOut, RoutePaths.chat), RoutePaths.login);
      expect(resolveRedirect(signedOut, RoutePaths.settings), RoutePaths.login);
    });

    test('keeps signed-in users away from login and register', () {
      expect(resolveRedirect(signedIn, RoutePaths.login), RoutePaths.chat);
      expect(resolveRedirect(signedIn, RoutePaths.register), RoutePaths.chat);
    });

    test('allows public and permitted routes', () {
      expect(resolveRedirect(signedOut, RoutePaths.login), isNull);
      expect(resolveRedirect(signedOut, RoutePaths.register), isNull);
      expect(resolveRedirect(signedOut, RoutePaths.designSystem), isNull);
      expect(resolveRedirect(signedIn, RoutePaths.chat), isNull);
      expect(resolveRedirect(signedIn, RoutePaths.settings), isNull);
    });
  });
}
