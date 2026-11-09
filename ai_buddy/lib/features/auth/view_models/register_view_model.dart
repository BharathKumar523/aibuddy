import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';
import 'package:ai_buddy/features/auth/view_models/auth_form_errors.dart';
import 'package:ai_buddy/features/auth/view_models/auth_form_state.dart';

/// Drives the registration form. Disposed when the screen closes.
final registerViewModelProvider =
    NotifierProvider.autoDispose<RegisterViewModel, AuthFormState>(
  RegisterViewModel.new,
  name: 'registerViewModelProvider',
);

class RegisterViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  /// Creates the account and signs in. A taken email is shown under the
  /// email field.
  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) return;
    state = const AuthFormState(isSubmitting: true);

    final repository = ref.read(authRepositoryProvider);
    final session = ref.read(sessionViewModelProvider.notifier);

    try {
      final user = await repository.register(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );
      session.setAuthenticated(user);
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = authFormErrorState(ErrorMapper.map(error, stackTrace));
    }
  }

  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field) && state.errorMessage == null) return;
    state = state.copyWith(
      errorMessage: null,
      fieldErrors: Map.of(state.fieldErrors)..remove(field),
    );
  }
}
