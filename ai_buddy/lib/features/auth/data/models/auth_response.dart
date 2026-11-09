import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ai_buddy/features/auth/data/models/user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// `data` of `POST /api/auth/register` and `POST /api/auth/login`.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required User user,
    required String accessToken,
    @Default('Bearer') String tokenType,

    /// Token lifetime in seconds.
    required int expiresIn,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
