import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';
import 'package:ai_buddy/features/auth/view_models/auth_form_errors.dart';
import 'package:ai_buddy/features/auth/view_models/auth_form_state.dart';

/// Drives the login form. Disposed when the login screen closes.
final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, AuthFormState>(
  LoginViewModel.new,
  name: 'loginViewModelProvider',
);

class LoginViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  /// Signs in. On success the session becomes authenticated and the router
  /// leaves the login screen by itself; nothing else to do here.
  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) return;
    state = const AuthFormState(isSubmitting: true);

    // Read dependencies before awaiting: this provider may be disposed
    // (screen closed) by the time the request finishes.
    final repository = ref.read(authRepositoryProvider);
    final session = ref.read(sessionViewModelProvider.notifier);

    try {
      final user = await repository.login(
        email: email.trim().toLowerCase(),
        password: password,
      );
      session.setAuthenticated(user);
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = authFormErrorState(ErrorMapper.map(error, stackTrace));
    }
  }

  /// Clears a server error once the user edits that field again.
  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field) && state.errorMessage == null) return;
    state = state.copyWith(
      errorMessage: null,
      fieldErrors: Map.of(state.fieldErrors)..remove(field),
    );
  }
}
