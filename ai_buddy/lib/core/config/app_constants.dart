/// App-wide constants. Keep magic numbers here, not in widgets.
abstract final class AppConstants {
  static const String appName = 'AI Buddy';

  // Networking
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Chat limits (must match backend validation)
  static const int maxMessageLength = 8000;
  static const int maxTitleLength = 100;

  // Pagination
  static const int conversationsPageSize = 20;
  static const int messagesPageSize = 30;
}
