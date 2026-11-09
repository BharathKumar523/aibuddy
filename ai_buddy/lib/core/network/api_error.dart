import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

/// The `error` object of the backend's failure envelope:
///
/// ```json
/// { "success": false,
///   "error": { "code": "VALIDATION_ERROR", "message": "...",
///              "details": [ { "field": "email", "message": "..." } ] } }
/// ```
@freezed
abstract class ApiError with _$ApiError {
  const factory ApiError({
    @Default('UNKNOWN_ERROR') String code,
    @Default('Something went wrong.') String message,
    @Default(<ApiFieldError>[]) List<ApiFieldError> details,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

/// One validation problem for a single request field.
@freezed
abstract class ApiFieldError with _$ApiFieldError {
  const factory ApiFieldError({
    String? field,
    @Default('Invalid value.') String message,
  }) = _ApiFieldError;

  factory ApiFieldError.fromJson(Map<String, dynamic> json) =>
      _$ApiFieldErrorFromJson(json);
}
