import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ai_buddy/features/auth/data/models/user.dart';

part 'session_state.freezed.dart';

/// Who is using the app right now.
///
/// While `sessionViewModelProvider` is loading (or failed to restore), there
/// is no SessionState yet and the router keeps the user on the splash screen.
@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.authenticated(User user) = SessionAuthenticated;
  const factory SessionState.unauthenticated() = SessionUnauthenticated;
}
