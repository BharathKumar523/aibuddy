import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/features/auth/views/widgets/sign_out_dialog.dart';
import 'package:ai_buddy/features/settings/views/widgets/theme_mode_selector.dart';

/// Settings: account (opens the profile), appearance, sign-out.
/// Phase 9 adds history clearing and version info.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            if (user != null) ...<Widget>[
              Text('Account', style: context.textStyles.titleSmall),
              Gap.h8,
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.primaryContainer,
                  foregroundColor: context.colors.onPrimaryContainer,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  ),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RoutePaths.profile),
              ),
              Gap.h24,
            ],
            Text('Appearance', style: context.textStyles.titleSmall),
            Gap.h12,
            const ThemeModeSelector(),
            Gap.h32,
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Design system'),
              subtitle: const Text('Preview components and colors'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(RoutePaths.designSystem),
            ),
            if (user != null)
              ListTile(
                leading: Icon(Icons.logout_rounded, color: context.colors.error),
                title: Text(
                  'Sign out',
                  style: TextStyle(color: context.colors.error),
                ),
                onTap: () => unawaited(confirmSignOut(context, ref)),
              ),
          ],
        ),
      ),
    );
  }
}
