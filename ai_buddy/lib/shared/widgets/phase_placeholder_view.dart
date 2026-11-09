import 'package:flutter/material.dart';

import 'package:ai_buddy/shared/widgets/state_views.dart';

/// Marks a screen whose feature lands in a later, named phase.
///
/// Used only so the router has real destinations during Phase 2. Each use
/// is replaced by the real screen in the phase it names.
class PhasePlaceholderView extends StatelessWidget {
  const PhasePlaceholderView({
    super.key,
    required this.title,
    required this.phase,
    required this.description,
    this.icon = Icons.construction_rounded,
    this.action,
  });

  final String title;
  final int phase;
  final String description;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: icon,
      title: title,
      message: '$description\n\nArrives in Phase $phase.',
      action: action,
    );
  }
}
