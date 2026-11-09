import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/session/session_view_model.dart';
import 'package:ai_buddy/core/theme/app_theme.dart';
import 'package:ai_buddy/features/chat/data/repositories/chat_repository.dart';
import 'package:ai_buddy/features/chat/data/repositories/mock_chat_repository.dart';
import 'package:ai_buddy/features/chat/views/chat_screen.dart';

import '../../helpers/fakes.dart';

void main() {
  Widget buildScreen({Duration chunkDelay = Duration.zero}) {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        currentUserProvider.overrideWithValue(testUser),
        chatRepositoryProvider.overrideWithValue(
          MockChatRepository(latency: Duration.zero, chunkDelay: chunkDelay),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const ChatScreen()),
    );
  }

  /// Long replies push earlier messages above the screen, where a list
  /// doesn't build them. Drag the message list down to reveal [finder].
  Future<void> scrollUpTo(WidgetTester tester, Finder finder) async {
    await tester.dragUntilVisible(finder, find.byType(ListView), const Offset(0, 250));
    await tester.pumpAndSettle();
  }

  Future<void> sendText(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('chat_input')), text);
    await tester.pump();
    await tester.tap(find.byKey(const Key('chat_send')));
  }

  testWidgets('new chat shows the welcome view and suggested prompts', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Hi, Ada!'), findsOneWidget);
    expect(find.text('How can I help you today?'), findsOneWidget);
    expect(find.text('Explain JWT authentication'), findsOneWidget);
    expect(find.text('Write a Dart debounce function'), findsOneWidget);
  });

  testWidgets('send is disabled until something is typed', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    IconButton sendButton() => tester.widget<IconButton>(find.byKey(const Key('chat_send')));
    expect(sendButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('chat_input')), '   ');
    await tester.pump();
    expect(sendButton().onPressed, isNull, reason: 'whitespace only');

    await tester.enterText(find.byKey(const Key('chat_input')), 'Hello');
    await tester.pump();
    expect(sendButton().onPressed, isNotNull);
  });

  testWidgets('a suggested prompt is sent and the reply renders code blocks',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Write a Dart debounce function'));
    await tester.pumpAndSettle();

    // The newest content (end of the reply) is on screen.
    expect(find.byTooltip('Copy message'), findsOneWidget);
    expect(find.byTooltip('Copy code'), findsWidgets);
    expect(find.text('dart'), findsWidgets);

    // The prompt sits above the long reply.
    const prompt = 'Write a Dart function that debounces a callback.';
    await scrollUpTo(tester, find.text(prompt));
    expect(find.text(prompt), findsOneWidget);
  });

  testWidgets('typing and sending clears the input and shows the message', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await sendText(tester, 'Hello there');
    await tester.pumpAndSettle();

    // The mock reply quotes the prompt, so the text appears more than once.
    expect(find.text('Hello there'), findsWidgets);
    final input = tester.widget<TextField>(find.byKey(const Key('chat_input')));
    expect(input.controller?.text, isEmpty);
    expect(find.byTooltip('Copy message'), findsOneWidget);
  });

  testWidgets('a failed reply shows the error and Retry recovers it', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await sendText(tester, 'please fail');
    await tester.pumpAndSettle();

    const errorText = 'The AI service is temporarily unavailable. Please try again.';
    expect(find.text(errorText), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text(errorText), findsNothing);
    expect(find.byTooltip('Copy message'), findsOneWidget);
  });

  testWidgets('Stop ends the reply and offers Retry', (tester) async {
    await tester.pumpWidget(
      buildScreen(chunkDelay: const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    await sendText(tester, 'Explain JWT');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('chat_stop')), findsOneWidget);
    await tester.tap(find.byKey(const Key('chat_stop')));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Response stopped.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byKey(const Key('chat_send')), findsOneWidget);
  });

  testWidgets('the drawer lists conversations and opens one', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Conversations'));
    await tester.pumpAndSettle();

    expect(find.text('Debounce function in Dart'), findsOneWidget);
    expect(find.text('Weekend trip to Goa'), findsOneWidget);

    await tester.tap(find.text('Weekend trip to Goa'));
    await tester.pumpAndSettle();

    // Drawer closed, conversation open: title in the app bar, history shown.
    expect(find.text('Weekend trip to Goa'), findsOneWidget);
    const firstMessage = 'Plan a 2-day trip to Goa on a budget.';
    await scrollUpTo(tester, find.text(firstMessage));
    expect(find.text(firstMessage), findsOneWidget);
  });

  testWidgets('wide screens show the history as a side panel', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Conversations'), findsNothing);
    expect(find.text('Debounce function in Dart'), findsOneWidget);
    expect(find.text('Hi, Ada!'), findsOneWidget);
  });
}
