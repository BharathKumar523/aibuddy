import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/config/env.dart';
import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/features/system/data/models/health_status.dart';
import 'package:ai_buddy/features/system/view_models/health_view_model.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';

/// Calls `GET /api/health` through the full stack (View → ViewModel →
/// Repository → ApiClient → Dio) and shows every state.
class HealthCheckCard extends ConsumerWidget {
  const HealthCheckCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthViewModelProvider);
    final mutedStyle = context.textStyles.bodySmall?.copyWith(
      color: context.palette.mutedText,
    );

    final Widget result = switch (health) {
      AsyncLoading() => const LinearProgressIndicator(),
      AsyncError(:final error) => _StatusLine(
          icon: Icons.cloud_off_rounded,
          color: context.colors.error,
          text: ErrorMapper.map(error).message,
        ),
      AsyncData(value: final HealthStatus status) => _HealthDetails(status: status),
      AsyncData() => Text('Not checked yet.', style: mutedStyle),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Backend connection', style: context.textStyles.titleMedium),
            Gap.h4,
            Text(Env.apiBaseUrl, style: mutedStyle),
            Gap.h16,
            result,
            Gap.h16,
            AppButton(
              label: 'Check connection',
              icon: Icons.wifi_tethering_rounded,
              variant: AppButtonVariant.secondary,
              isLoading: health.isLoading,
              onPressed: () => unawaited(
                ref.read(healthViewModelProvider.notifier).check(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthDetails extends StatelessWidget {
  const _HealthDetails({required this.status});

  final HealthStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StatusLine(
          icon: status.isHealthy
              ? Icons.check_circle_rounded
              : Icons.warning_amber_rounded,
          color: status.isHealthy ? palette.success : palette.warning,
          text: status.isHealthy
              ? 'Server and database are up'
              : 'Server responded, database is ${status.db}',
        ),
        Gap.h8,
        Text(
          'Uptime ${status.uptime.toStringAsFixed(0)} s',
          style: context.textStyles.bodySmall,
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: color, size: 20),
        Gap.w8,
        Expanded(child: Text(text, style: context.textStyles.bodyMedium)),
      ],
    );
  }
}
