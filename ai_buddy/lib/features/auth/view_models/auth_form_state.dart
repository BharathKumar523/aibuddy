import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_form_state.freezed.dart';

/// UI state shared by the login and registration forms.
@freezed
abstract class AuthFormState with _$AuthFormState {
  const factory AuthFormState({
    /// A request is in flight: the submit button shows a spinner and the
    /// fields are disabled, which also prevents double submission.
    @Default(false) bool isSubmitting,

    /// Form-level error shown in a banner (wrong password, offline, ...).
    String? errorMessage,

    /// Server-side errors for individual fields, e.g. `{'email': 'An account
    /// with this email already exists.'}`, shown under those fields.
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _AuthFormState;
}
