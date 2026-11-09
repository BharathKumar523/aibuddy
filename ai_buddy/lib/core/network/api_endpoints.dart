/// Every backend path in one place, relative to `Env.apiBaseUrl`
/// (which already ends in `/api`).
abstract final class ApiEndpoints {
  // Health
  static const String health = '/health';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Conversations
  static const String conversations = '/conversations';
  static String conversation(String id) => '/conversations/$id';

  // Messages
  static String messages(String conversationId) =>
      '/conversations/$conversationId/messages';
  static String messagesStream(String conversationId) =>
      '/conversations/$conversationId/messages/stream';

  // Profile
  static const String profile = '/users/profile';
}
