import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/core/session/session_state.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/auth/views/login_screen.dart';
import 'package:ai_buddy/features/auth/views/register_screen.dart';
import 'package:ai_buddy/features/auth/views/splash_screen.dart';
import 'package:ai_buddy/features/chat/views/chat_screen.dart';
import 'package:ai_buddy/features/profile/views/profile_screen.dart';
import 'package:ai_buddy/features/settings/views/settings_screen.dart';
import 'package:ai_buddy/features/system/views/design_system_screen.dart';
import 'package:ai_buddy/features/system/views/not_found_screen.dart';

/// Decides where a user may go given the current session.
///
/// A pure function, kept outside GoRouter so it can be unit-tested.
/// Returns `null` to allow the navigation, or a path to redirect to.
String? resolveRedirect(AsyncValue<SessionState> session, String location) {
  final state = session.value;

  // Session not resolved yet (loading, or restore failed and the splash is
  // offering Retry): hold everyone on the splash screen.
  if (state == null) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  final isAuthenticated = state is SessionAuthenticated;

  if (location == RoutePaths.splash) {
    return isAuthenticated ? RoutePaths.chat : RoutePaths.login;
  }
  if (!isAuthenticated && !RoutePaths.public.contains(location)) {
    return RoutePaths.login;
  }
  if (isAuthenticated && RoutePaths.guestOnly.contains(location)) {
    return RoutePaths.chat;
  }
  return null;
}

/// The app's GoRouter.
///
/// It's created once. Session changes don't rebuild it; they call
/// [_RouterRefreshNotifier.notify], which makes GoRouter re-run `redirect`.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref.listen<AsyncValue<SessionState>>(
    sessionViewModelProvider,
    (_, _) => refresh.notify(),
  );

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      ref.read(sessionViewModelProvider),
      state.matchedLocation,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.chat,
        name: RouteNames.chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.designSystem,
        name: RouteNames.designSystem,
        builder: (context, state) => const DesignSystemScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        NotFoundScreen(location: state.uri.toString()),
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}, name: 'routerProvider');

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
