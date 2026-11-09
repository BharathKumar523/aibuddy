// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) =>
    _HealthStatus(
      status: json['status'] as String? ?? 'unknown',
      db: json['db'] as String? ?? 'unknown',
      version: json['version'] as String? ?? 'unknown',
      uptime: (json['uptime'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$HealthStatusToJson(_HealthStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'db': instance.db,
      'version': instance.version,
      'uptime': instance.uptime,
    };
