import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/errors/error_mapper.dart';
import 'package:ai_buddy/shared/widgets/state_views.dart';

/// Renders the loading / error / data states of an [AsyncValue] the same
/// way everywhere, so each screen only describes its success UI.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const LoadingView(),
      error: (error, stackTrace) => ErrorView(
        message: ErrorMapper.map(error, stackTrace).message,
        onRetry: onRetry,
      ),
    );
  }
}
