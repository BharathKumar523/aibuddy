import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/features/auth/view_models/auth_form_state.dart';

/// Turns a failed auth request into form state: field errors go under
/// their fields, everything else into the banner.
AuthFormState authFormErrorState(AppException error) {
  return switch (error) {
    ValidationException(:final fieldErrors) when fieldErrors.isNotEmpty =>
      AuthFormState(fieldErrors: fieldErrors),
    ConflictException(code: 'EMAIL_TAKEN', :final message) =>
      AuthFormState(fieldErrors: <String, String>{'email': message}),
    _ => AuthFormState(errorMessage: error.message),
  };
}
