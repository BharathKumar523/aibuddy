/// URL paths for every screen.
abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String designSystem = '/design-system';

  /// Reachable without a session.
  static const Set<String> public = {splash, login, register, designSystem};

  /// Only for signed-out users. Signed-in users are sent to [chat].
  static const Set<String> guestOnly = {login, register};
}

/// Route names, for `context.goNamed(...)`.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String chat = 'chat';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String designSystem = 'designSystem';
}
