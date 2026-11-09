import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/core/utils/validators.dart';
import 'package:ai_buddy/features/auth/view_models/register_view_model.dart';
import 'package:ai_buddy/features/auth/views/widgets/auth_scaffold.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/app_text_field.dart';
import 'package:ai_buddy/shared/widgets/error_banner.dart';

/// Account creation form: name, email, password and confirmation.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    unawaited(
      ref.read(registerViewModelProvider.notifier).submit(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          ),
    );
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registerViewModelProvider);
    final viewModel = ref.read(registerViewModelProvider.notifier);
    final errorMessage = form.errorMessage;
    final enabled = !form.isSubmitting;

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'It only takes a minute.',
      showBackButton: context.canPop(),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (errorMessage != null) ...<Widget>[
                ErrorBanner(message: errorMessage),
                Gap.h16,
              ],
              AppTextField(
                key: const Key('register_name'),
                controller: _nameController,
                label: 'Name',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.name],
                maxLength: Validators.nameMax,
                enabled: enabled,
                validator: Validators.name,
                errorText: form.fieldErrors['name'],
                onChanged: (_) => viewModel.clearFieldError('name'),
              ),
              Gap.h16,
              AppTextField(
                key: const Key('register_email'),
                controller: _emailController,
                label: 'Email',
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                autocorrect: false,
                enabled: enabled,
                validator: Validators.email,
                errorText: form.fieldErrors['email'],
                onChanged: (_) => viewModel.clearFieldError('email'),
              ),
              Gap.h16,
              AppTextField(
                key: const Key('register_password'),
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.newPassword],
                enabled: enabled,
                validator: Validators.newPassword,
                errorText: form.fieldErrors['password'],
                onChanged: (_) => viewModel.clearFieldError('password'),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  top: AppSpacing.xs,
                ),
                child: Text(
                  'At least 8 characters, with a letter and a number.',
                  style: context.textStyles.bodySmall,
                ),
              ),
              Gap.h16,
              AppTextField(
                key: const Key('register_confirm'),
                controller: _confirmController,
                label: 'Confirm password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: enabled,
                validator: Validators.confirmPassword(
                  () => _passwordController.text,
                ),
                onSubmitted: (_) => _submit(),
              ),
              Gap.h24,
              AppButton(
                key: const Key('register_submit'),
                label: 'Create account',
                isLoading: form.isSubmitting,
                onPressed: _submit,
              ),
              Gap.h16,
              // Wrap, not Row: moves the link to a second line on narrow
              // screens or with large accessibility font sizes.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'Already have an account?',
                    style: context.textStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: enabled ? _goToLogin : null,
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
