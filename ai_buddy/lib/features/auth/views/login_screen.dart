import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_buddy/core/router/route_paths.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/core/utils/validators.dart';
import 'package:ai_buddy/features/auth/view_models/login_view_model.dart';
import 'package:ai_buddy/features/auth/views/widgets/auth_scaffold.dart';
import 'package:ai_buddy/shared/widgets/app_button.dart';
import 'package:ai_buddy/shared/widgets/app_text_field.dart';
import 'package:ai_buddy/shared/widgets/error_banner.dart';

/// Sign-in form. Validation rules live in [Validators]; the request, its
/// errors and the loading state live in [LoginViewModel].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    unawaited(
      ref.read(loginViewModelProvider.notifier).submit(
            email: _emailController.text,
            password: _passwordController.text,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);
    final errorMessage = form.errorMessage;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue chatting with AI Buddy.',
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
                key: const Key('login_email'),
                controller: _emailController,
                label: 'Email',
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                autocorrect: false,
                enabled: !form.isSubmitting,
                validator: Validators.email,
                errorText: form.fieldErrors['email'],
                onChanged: (_) => viewModel.clearFieldError('email'),
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              Gap.h16,
              AppTextField(
                key: const Key('login_password'),
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.password],
                enabled: !form.isSubmitting,
                validator: Validators.loginPassword,
                errorText: form.fieldErrors['password'],
                onChanged: (_) => viewModel.clearFieldError('password'),
                onSubmitted: (_) => _submit(),
              ),
              Gap.h24,
              AppButton(
                key: const Key('login_submit'),
                label: 'Sign in',
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
                    "Don't have an account?",
                    style: context.textStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: form.isSubmitting
                        ? null
                        : () => context.push(RoutePaths.register),
                    child: const Text('Create one'),
                  ),
                ],
              ),
              if (kDebugMode)
                TextButton(
                  onPressed: () => context.push(RoutePaths.designSystem),
                  child: const Text('Design system (debug)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
