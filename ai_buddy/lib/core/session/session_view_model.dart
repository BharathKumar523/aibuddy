import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/session/session_state.dart';
import 'package:ai_buddy/core/session/unauthorized_signal.dart';
import 'package:ai_buddy/core/utils/app_logger.dart';
import 'package:ai_buddy/features/auth/data/models/user.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';

/// App-wide session, read by the router guard and every signed-in screen.
///
/// Restoring on app start:
///   * no stored token          → unauthenticated (login screen)
///   * token, /auth/me succeeds → authenticated(user) (chat)
///   * token, /auth/me says 401 → token deleted → unauthenticated
///   * token, server unreachable → AsyncError. The splash screen offers
///     Retry. The user is NOT signed out just for being offline.
final sessionViewModelProvider =
    AsyncNotifierProvider<SessionViewModel, SessionState>(
  SessionViewModel.new,
  name: 'sessionViewModelProvider',
);

/// The signed-in user, or null. Convenience for screens.
final currentUserProvider = Provider<User?>((ref) {
  return switch (ref.watch(sessionViewModelProvider).value) {
    SessionAuthenticated(:final user) => user,
    _ => null,
  };
}, name: 'currentUserProvider');

class SessionViewModel extends AsyncNotifier<SessionState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<SessionState> build() async {
    final subscription = ref
        .watch(unauthorizedSignalProvider)
        .stream
        .listen((_) => unawaited(handleUnauthorized()));
    ref.onDispose(subscription.cancel);

    final repository = ref.watch(authRepositoryProvider);

    var hasToken = false;
    try {
      hasToken = await repository.hasStoredSession();
    } on Object catch (e, st) {
      // A corrupted keystore entry must not trap the user on the splash
      // screen. Treat it as signed out and drop the bad value.
      AppLogger.error('Failed to read stored session', error: e, stackTrace: st);
      await _safeLogout(repository);
      return const SessionState.unauthenticated();
    }

    if (!hasToken) return const SessionState.unauthenticated();

    try {
      final user = await repository.currentUser();
      return SessionState.authenticated(user);
    } on UnauthorizedException {
      // Expired, revoked, or the account was deleted.
      await _safeLogout(repository);
      return const SessionState.unauthenticated();
    }
    // Any other AppException (offline, timeout, 5xx) propagates and
    // becomes AsyncError, which the splash screen shows with Retry.
  }

  /// Called after a successful login or registration.
  /// The repository has already stored the token.
  void setAuthenticated(User user) {
    state = AsyncData(SessionState.authenticated(user));
  }

  /// Retries restoring the session (splash "Try again").
  void retry() => ref.invalidateSelf();

  /// Deletes the token. The router redirects to login automatically.
  Future<void> signOut() async {
    await _safeLogout(_repository);
    state = const AsyncData(SessionState.unauthenticated());
  }

  /// The server rejected our token mid-session (expired, account deleted).
  Future<void> handleUnauthorized() async {
    // During restore, build() handles the 401 itself.
    if (state.isLoading || state.value is! SessionAuthenticated) return;
    AppLogger.info('Token rejected by server, signing out', tag: 'Session');
    await signOut();
  }

  Future<void> _safeLogout(AuthRepository repository) async {
    try {
      await repository.logout();
    } on Object catch (e, st) {
      AppLogger.error('Failed to clear token', error: e, stackTrace: st);
    }
  }
}
