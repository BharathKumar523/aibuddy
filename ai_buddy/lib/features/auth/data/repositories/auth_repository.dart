import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/network/api_client.dart';
import 'package:ai_buddy/core/network/api_endpoints.dart';
import 'package:ai_buddy/core/network/api_response.dart';
import 'package:ai_buddy/core/network/network_providers.dart';
import 'package:ai_buddy/core/storage/storage_providers.dart';
import 'package:ai_buddy/core/storage/token_storage.dart';
import 'package:ai_buddy/features/auth/data/models/auth_response.dart';
import 'package:ai_buddy/features/auth/data/models/user.dart';

/// Everything about signing in and out.
///
/// Every method throws an `AppException` on failure. The repository owns
/// the token: it saves it after register/login and deletes it on logout,
/// so ViewModels never touch secure storage.
abstract interface class AuthRepository {
  /// Creates an account, stores the token, returns the new user.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  /// Signs in, stores the token, returns the user.
  Future<User> login({required String email, required String password});

  /// Fetches the user for the stored token (`GET /api/auth/me`).
  Future<User> currentUser();

  /// Whether a token is stored on this device.
  Future<bool> hasStoredSession();

  /// Deletes the stored token. The JWT is stateless, so no server call.
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required ApiClient api, required TokenStorage tokenStorage})
      : _api = api,
        _tokenStorage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post<AuthResponse>(
      ApiEndpoints.register,
      authenticated: false,
      data: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      },
      parser: (json) => AuthResponse.fromJson(asJsonMap(json)),
    );
    await _tokenStorage.saveAccessToken(response.data.accessToken);
    return response.data.user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await _api.post<AuthResponse>(
      ApiEndpoints.login,
      authenticated: false,
      data: <String, dynamic>{'email': email, 'password': password},
      parser: (json) => AuthResponse.fromJson(asJsonMap(json)),
    );
    await _tokenStorage.saveAccessToken(response.data.accessToken);
    return response.data.user;
  }

  @override
  Future<User> currentUser() async {
    final response = await _api.get<User>(
      ApiEndpoints.me,
      parser: (json) => User.fromJson(asJsonMap(asJsonMap(json)['user'])),
    );
    return response.data;
  }

  @override
  Future<bool> hasStoredSession() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() => _tokenStorage.clear();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    api: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
  name: 'authRepositoryProvider',
);
