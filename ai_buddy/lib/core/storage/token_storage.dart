import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the JWT access token.
///
/// Abstract so ViewModel and network tests can use an in-memory fake.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> clear();
}

/// [TokenStorage] backed by the iOS Keychain / Android Keystore.
///
/// The token is cached in memory after the first read, because every API
/// request reads it and keystore access is comparatively slow.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'ai_buddy_access_token';

  final FlutterSecureStorage _storage;
  String? _cachedToken;
  bool _hasLoaded = false;

  @override
  Future<String?> readAccessToken() async {
    if (_hasLoaded) return _cachedToken;
    _cachedToken = await _storage.read(key: _accessTokenKey);
    _hasLoaded = true;
    return _cachedToken;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    _cachedToken = token;
    _hasLoaded = true;
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    _cachedToken = null;
    _hasLoaded = true;
  }
}
