import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';
import 'package:ai_buddy/shared/widgets/app_logo.dart';

/// A suggested first message.
class SuggestedPrompt {
  const SuggestedPrompt({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// The exact text sent when tapped.
  final String prompt;
}

const List<SuggestedPrompt> suggestedPrompts = <SuggestedPrompt>[
  SuggestedPrompt(
    icon: Icons.lock_outline_rounded,
    title: 'Explain JWT authentication',
    subtitle: 'How access tokens keep users signed in',
    prompt: 'Explain how JWT authentication works in a mobile app.',
  ),
  SuggestedPrompt(
    icon: Icons.code_rounded,
    title: 'Write a Dart debounce function',
    subtitle: 'Reusable helper for search boxes',
    prompt: 'Write a Dart function that debounces a callback.',
  ),
  SuggestedPrompt(
    icon: Icons.flight_takeoff_rounded,
    title: 'Plan a weekend trip',
    subtitle: '2 days in Goa on a budget',
    prompt: 'Plan a 2-day trip to Goa on a budget.',
  ),
  SuggestedPrompt(
    icon: Icons.account_tree_outlined,
    title: 'Why use MVVM?',
    subtitle: 'Benefits of MVVM in Flutter apps',
    prompt: 'What are the benefits of MVVM in Flutter?',
  ),
];

/// Empty-chat screen: greeting and suggested prompts.
class WelcomeView extends StatelessWidget {
  const WelcomeView({
    super.key,
    required this.userName,
    required this.onPromptSelected,
  });

  final String? userName;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final firstName = userName?.trim().split(RegExp(r'\s+')).first;
    final greeting =
        (firstName == null || firstName.isEmpty) ? 'Hi there!' : 'Hi, $firstName!';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(child: AppLogo(size: 56)),
              Gap.h16,
              Text(
                greeting,
                textAlign: TextAlign.center,
                style: context.textStyles.headlineMedium,
              ),
              Gap.h8,
              Text(
                'How can I help you today?',
                textAlign: TextAlign.center,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
              Gap.h32,
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 480;
                  final width = twoColumns
                      ? (constraints.maxWidth - AppSpacing.md) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: <Widget>[
                      for (final suggestion in suggestedPrompts)
                        SizedBox(
                          width: width,
                          child: _PromptCard(
                            suggestion: suggestion,
                            onTap: () => onPromptSelected(suggestion.prompt),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.suggestion, required this.onTap});

  final SuggestedPrompt suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Icon(suggestion.icon, color: context.colors.primary),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(suggestion.title, style: context.textStyles.titleSmall),
                    Gap.h4,
                    Text(suggestion.subtitle, style: context.textStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
