import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ai_buddy/core/theme/theme_extensions.dart';

/// Three pulsing dots shown before the first chunk of a reply arrives.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.palette.mutedText;
    return Semantics(
      label: 'AI Buddy is typing',
      child: SizedBox(
        height: 24,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: _opacityFor(i),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: const SizedBox.square(dimension: 8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Each dot peaks a third of a cycle after the previous one.
  double _opacityFor(int index) {
    final phase = (_controller.value - index / 3) * 2 * math.pi;
    return 0.3 + 0.7 * (0.5 + 0.5 * math.sin(phase));
  }
}
