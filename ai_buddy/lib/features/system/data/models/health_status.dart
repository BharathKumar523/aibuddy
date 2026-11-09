import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_status.freezed.dart';
part 'health_status.g.dart';

/// Response of `GET /api/health`.
@freezed
abstract class HealthStatus with _$HealthStatus {
  const HealthStatus._();

  const factory HealthStatus({
    @Default('unknown') String status,
    @Default('unknown') String db,
    @Default('unknown') String version,
    @Default(0.0) double uptime,
  }) = _HealthStatus;

  factory HealthStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthStatusFromJson(json);

  bool get isHealthy => status == 'ok' && db == 'up';
}
