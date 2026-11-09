import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/features/system/data/models/health_status.dart';
import 'package:ai_buddy/features/system/data/repositories/health_repository.dart';
import 'package:ai_buddy/features/system/view_models/health_view_model.dart';

class MockHealthRepository extends Mock implements HealthRepository {}

void main() {
  late MockHealthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockHealthRepository();
    container = ProviderContainer(
      overrides: [healthRepositoryProvider.overrideWithValue(repository)],
    );
    // The provider is autoDispose; keep it alive for the whole test.
    container.listen(healthViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('starts idle', () {
    final state = container.read(healthViewModelProvider);
    expect(state, isA<AsyncData<HealthStatus?>>());
    expect(state.value, isNull);
  });

  test('exposes the status on success', () async {
    const status = HealthStatus(status: 'ok', db: 'up', version: '1.0.0');
    when(() => repository.check()).thenAnswer((_) async => status);

    await container.read(healthViewModelProvider.notifier).check();

    final state = container.read(healthViewModelProvider);
    expect(state.value, status);
    expect(state.value!.isHealthy, isTrue);
  });

  test('exposes the AppException on failure', () async {
    when(() => repository.check()).thenThrow(const NetworkException());

    await container.read(healthViewModelProvider.notifier).check();

    final state = container.read(healthViewModelProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<NetworkException>());
  });
}
