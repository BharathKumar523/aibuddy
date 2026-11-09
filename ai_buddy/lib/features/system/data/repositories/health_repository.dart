import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/network/api_client.dart';
import 'package:ai_buddy/core/network/api_endpoints.dart';
import 'package:ai_buddy/core/network/api_response.dart';
import 'package:ai_buddy/core/network/network_providers.dart';
import 'package:ai_buddy/features/system/data/models/health_status.dart';

/// Checks whether the backend and its database are reachable.
abstract interface class HealthRepository {
  /// Throws an `AppException` on failure.
  Future<HealthStatus> check();
}

class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<HealthStatus> check() async {
    final response = await _api.get<HealthStatus>(
      ApiEndpoints.health,
      authenticated: false,
      parser: (json) => HealthStatus.fromJson(asJsonMap(json)),
    );
    return response.data;
  }
}

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => HealthRepositoryImpl(ref.watch(apiClientProvider)),
  name: 'healthRepositoryProvider',
);
