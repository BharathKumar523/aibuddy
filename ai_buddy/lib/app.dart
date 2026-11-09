import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_buddy/core/config/app_constants.dart';
import 'package:ai_buddy/core/router/app_router.dart';
import 'package:ai_buddy/core/theme/app_theme.dart';
import 'package:ai_buddy/features/settings/view_models/theme_view_model.dart';

/// Root widget: wires the router and theme to their providers.
class AiBuddyApp extends ConsumerWidget {
  const AiBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
