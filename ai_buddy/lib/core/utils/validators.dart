import 'dart:convert';

/// Form validators. Rules mirror the backend's Zod schemas, so most
/// mistakes are caught before a request is sent. The server stays the
/// source of truth, and its field errors are shown in the same places.
///
/// Each returns an error message, or null when the value is valid, which
/// is the contract of `TextFormField.validator`.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);
  static final RegExp _digit = RegExp(r'\p{N}', unicode: true);

  static const int nameMin = 2;
  static const int nameMax = 50;
  static const int passwordMin = 8;
  static const int passwordMaxBytes = 72;

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Name is required.';
    if (name.length < nameMin) return 'Name must be at least $nameMin characters.';
    if (name.length > nameMax) return 'Name must be at most $nameMax characters.';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (email.length > 254 || !_email.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Sign-in: the password only has to be present.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }

  /// Registration: 8+ characters, a letter and a number, max 72 bytes
  /// (bcrypt's limit). Passwords are never trimmed.
  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required.';
    if (password.length < passwordMin) {
      return 'Password must be at least $passwordMin characters.';
    }
    if (utf8.encode(password).length > passwordMaxBytes) {
      return 'Password must be at most $passwordMaxBytes characters.';
    }
    if (!_letter.hasMatch(password) || !_digit.hasMatch(password)) {
      return 'Password must contain at least one letter and one number.';
    }
    return null;
  }

  /// Builds a validator that checks the value equals [original]'s current text.
  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password.';
      if (value != original()) return 'Passwords do not match.';
      return null;
    };
  }
}
