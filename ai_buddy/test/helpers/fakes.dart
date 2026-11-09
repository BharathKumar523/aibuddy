import 'package:mocktail/mocktail.dart';

import 'package:ai_buddy/core/storage/token_storage.dart';
import 'package:ai_buddy/features/auth/data/models/user.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';

/// In-memory [TokenStorage] for tests.
class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage({this.token, this.throwOnRead = false});

  String? token;
  bool throwOnRead;
  int clearCalls = 0;

  @override
  Future<String?> readAccessToken() async {
    if (throwOnRead) throw StateError('keystore unavailable');
    return token;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    this.token = token;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    token = null;
  }
}

class MockAuthRepository extends Mock implements AuthRepository {}

final testUser = User(
  id: '65a1b2c3d4e5f6a7b8c9d0e1',
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

/// Stubs the calls every app/session test needs, for a signed-out device.
MockAuthRepository signedOutRepository() {
  final repository = MockAuthRepository();
  when(repository.hasStoredSession).thenAnswer((_) async => false);
  when(repository.logout).thenAnswer((_) async {});
  return repository;
}

/// Stubs a device with a stored token whose `/auth/me` returns [user].
MockAuthRepository signedInRepository([User? user]) {
  final repository = MockAuthRepository();
  when(repository.hasStoredSession).thenAnswer((_) async => true);
  when(repository.currentUser).thenAnswer((_) async => user ?? testUser);
  when(repository.logout).thenAnswer((_) async {});
  return repository;
}
