// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => _ApiError(
  code: json['code'] as String? ?? 'UNKNOWN_ERROR',
  message: json['message'] as String? ?? 'Something went wrong.',
  details:
      (json['details'] as List<dynamic>?)
          ?.map((e) => ApiFieldError.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ApiFieldError>[],
);

Map<String, dynamic> _$ApiErrorToJson(_ApiError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'details': instance.details,
};

_ApiFieldError _$ApiFieldErrorFromJson(Map<String, dynamic> json) =>
    _ApiFieldError(
      field: json['field'] as String?,
      message: json['message'] as String? ?? 'Invalid value.',
    );

Map<String, dynamic> _$ApiFieldErrorToJson(_ApiFieldError instance) =>
    <String, dynamic>{'field': instance.field, 'message': instance.message};
