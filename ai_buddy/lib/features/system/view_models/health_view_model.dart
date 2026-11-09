import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/features/system/data/models/health_status.dart';
import 'package:ai_buddy/features/system/data/repositories/health_repository.dart';

/// State of the "Check connection" card.
///
/// * `AsyncData(null)`: not checked yet (idle)
/// * `AsyncLoading`: request in flight
/// * `AsyncData(status)`: the server answered
/// * `AsyncError(AppException)`: request failed
final healthViewModelProvider =
    AsyncNotifierProvider.autoDispose<HealthViewModel, HealthStatus?>(
  HealthViewModel.new,
  name: 'healthViewModelProvider',
);

class HealthViewModel extends AsyncNotifier<HealthStatus?> {
  @override
  FutureOr<HealthStatus?> build() => null; // synchronous idle state

  Future<void> check() async {
    if (state.isLoading) return;
    state = const AsyncLoading<HealthStatus?>();
    final result = await AsyncValue.guard<HealthStatus?>(
      () => ref.read(healthRepositoryProvider).check(),
    );
    // The screen may have closed while the request was in flight.
    if (!ref.mounted) return;
    state = result;
  }
}
