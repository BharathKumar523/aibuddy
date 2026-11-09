import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/state_views.dart';

/// Shown by GoRouter for unknown locations.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyView(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'Nothing lives at "$location".',
        action: AppButton(
          label: 'Go home',
          expand: false,
          onPressed: () => context.go(RoutePaths.splash),
        ),
      ),
    );
  }
}
