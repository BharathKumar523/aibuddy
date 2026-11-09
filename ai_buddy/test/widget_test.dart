import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_buddy/app.dart';
import 'package:ai_buddy/core/errors/app_exception.dart';
import 'package:ai_buddy/core/storage/preferences_service.dart';
import 'package:ai_buddy/core/storage/storage_providers.dart';
import 'package:ai_buddy/features/auth/data/repositories/auth_repository.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/data/repositories/mock_chat_repository.dart';

import 'helpers/fakes.dart';

/// Full-app flows: boot, session restore, sign in, register, sign out.
/// Only the AuthRepository is faked; ViewModels, router and screens are real.
void main() {
  Widget buildApp(MockAuthRepository repository) {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        chatRepositoryProvider.overrideWithValue(
          MockChatRepository(latency: Duration.zero, chunkDelay: Duration.zero),
        ),
        preferencesServiceProvider.overrideWithValue(InMemoryPreferencesService()),
      ],
      child: const AiBuddyApp(),
    );
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('app start', () {
    testWidgets('no stored session → login screen', (tester) async {
      await tester.pumpWidget(buildApp(signedOutRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('valid stored session → chat greets the user', (tester) async {
      await tester.pumpWidget(buildApp(signedInRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Hi, Ada!'), findsOneWidget);
    });

    testWidgets('offline with a stored session → splash offers retry', (tester) async {
      final repository = signedInRepository();
      when(repository.currentUser).thenThrow(const NetworkException());

      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text(const NetworkException().message), findsOneWidget);
      verifyNever(repository.logout);

      when(repository.currentUser).thenAnswer((_) async => testUser);
      await tapAndSettle(tester, find.text('Try again'));

      expect(find.text('Hi, Ada!'), findsOneWidget);
    });
  });

  group('login', () {
    testWidgets('validates the form before sending anything', (tester) async {
      final repository = signedOutRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.byKey(const Key('login_submit')));

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      verifyNever(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('signs in and lands on chat', (tester) async {
      final repository = signedOutRepository();
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUser);

      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('login_email')), 'ada@example.com');
      await tester.enterText(find.byKey(const Key('login_password')), 'secret123');
      await tapAndSettle(tester, find.byKey(const Key('login_submit')));

      expect(find.text('Hi, Ada!'), findsOneWidget);
    });

    testWidgets('shows wrong credentials in a banner', (tester) async {
      final repository = signedOutRepository();
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const UnauthorizedException(
          message: 'Invalid email or password.',
          code: 'INVALID_CREDENTIALS',
        ),
      );

      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('login_email')), 'ada@example.com');
      await tester.enterText(find.byKey(const Key('login_password')), 'wrong');
      await tapAndSettle(tester, find.byKey(const Key('login_submit')));

      expect(find.text('Invalid email or password.'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });

  group('register', () {
    Future<void> openRegister(WidgetTester tester, MockAuthRepository repository) async {
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text('Create one'));
      expect(find.text('Create your account'), findsOneWidget);
    }

    Future<void> fillForm(WidgetTester tester, {String confirm = 'secret123'}) async {
      await tester.enterText(find.byKey(const Key('register_name')), 'Ada Lovelace');
      await tester.enterText(find.byKey(const Key('register_email')), 'ada@example.com');
      await tester.enterText(find.byKey(const Key('register_password')), 'secret123');
      await tester.enterText(find.byKey(const Key('register_confirm')), confirm);
    }

    testWidgets('requires matching passwords', (tester) async {
      await openRegister(tester, signedOutRepository());
      await fillForm(tester, confirm: 'different1');
      await tapAndSettle(tester, find.byKey(const Key('register_submit')));

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('creates the account and lands on chat', (tester) async {
      final repository = signedOutRepository();
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUser);

      await openRegister(tester, repository);
      await fillForm(tester);
      await tapAndSettle(tester, find.byKey(const Key('register_submit')));

      expect(find.text('Hi, Ada!'), findsOneWidget);
    });

    testWidgets('shows a taken email under the email field', (tester) async {
      final repository = signedOutRepository();
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ConflictException(
          message: 'An account with this email already exists.',
          code: 'EMAIL_TAKEN',
        ),
      );

      await openRegister(tester, repository);
      await fillForm(tester);
      await tapAndSettle(tester, find.byKey(const Key('register_submit')));

      expect(find.text('An account with this email already exists.'), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);
    });
  });

  testWidgets('sign out (drawer → settings) asks for confirmation, then returns to login',
      (tester) async {
    final repository = signedInRepository();
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byTooltip('Conversations'));
    await tapAndSettle(tester, find.byTooltip('Settings'));
    await tapAndSettle(tester, find.text('Sign out'));
    expect(find.text('Sign out?'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Sign out'));

    verify(repository.logout).called(1);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
