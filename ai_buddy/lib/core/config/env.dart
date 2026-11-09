/// Compile-time environment configuration.
///
/// Values are injected with `--dart-define-from-file=env/dev.json` (or
/// individual `--dart-define=KEY=value` flags). Nothing secret belongs here:
/// anything compiled into the app can be extracted from the APK. The OpenAI
/// key lives only on the backend.
abstract final class Env {
  /// Base URL of the ai-buddy-api backend, including the `/api` prefix.
  ///
  /// Default targets the Android emulator, where `10.0.2.2` is the host
  /// machine's `localhost`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );

  /// `development` or `production`.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';
}
