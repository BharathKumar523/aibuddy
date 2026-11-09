import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/features/auth/views/widgets/sign_out_dialog.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/state_views.dart';

/// The signed-in user's profile. Editing the name arrives with the profile
/// API in Phase 9.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const LoadingView()
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: <Widget>[
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: context.colors.primaryContainer,
                          foregroundColor: context.colors.onPrimaryContainer,
                          child: Text(
                            user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                            style: context.textStyles.headlineMedium?.copyWith(
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      Gap.h16,
                      Text(
                        user.name,
                        textAlign: TextAlign.center,
                        style: context.textStyles.headlineSmall,
                      ),
                      Gap.h4,
                      Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                      Gap.h32,
                      Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.person_outline_rounded),
                              title: const Text('Name'),
                              subtitle: Text(user.name),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.mail_outline_rounded),
                              title: const Text('Email'),
                              subtitle: Text(user.email),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.calendar_today_outlined),
                              title: const Text('Member since'),
                              subtitle: Text(
                                DateFormat.yMMMMd().format(user.createdAt.toLocal()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.h32,
                      AppButton(
                        label: 'Sign out',
                        icon: Icons.logout_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => unawaited(confirmSignOut(context, ref)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
