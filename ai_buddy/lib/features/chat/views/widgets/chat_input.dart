import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ai_buddy/core/config/app_constants.dart';
import 'package:ai_buddy/core/theme/app_radius.dart';
import 'package:ai_buddy/core/theme/app_spacing.dart';
import 'package:ai_buddy/core/theme/theme_extensions.dart';

/// Multiline composer with a Send button that turns into Stop while a reply
/// is being generated. Typing is still allowed while generating, so the
/// next question can be prepared.
class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
    this.enabled = true,
  });

  final bool isGenerating;
  final bool enabled;
  final ValueChanged<String> onSend;
  final VoidCallback onStop;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  static const int _counterThreshold = AppConstants.maxMessageLength - 500;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSend =>
      widget.enabled && !widget.isGenerating && _controller.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSend) return;
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final length = value.text.length;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: AppRadius.xlAll,
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                key: const Key('chat_input'),
                                controller: _controller,
                                focusNode: _focusNode,
                                enabled: widget.enabled,
                                minLines: 1,
                                maxLines: 6,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                textCapitalization: TextCapitalization.sentences,
                                maxLength: AppConstants.maxMessageLength,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                style: context.textStyles.bodyLarge,
                                decoration: const InputDecoration(
                                  hintText: 'Message AI Buddy…',
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  counterText: '',
                                  contentPadding: EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    AppSpacing.md,
                                    AppSpacing.sm,
                                    AppSpacing.md,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xs + 2),
                              child: widget.isGenerating
                                  ? IconButton.filled(
                                      key: const Key('chat_stop'),
                                      tooltip: 'Stop generating',
                                      onPressed: widget.onStop,
                                      icon: const Icon(Icons.stop_rounded),
                                    )
                                  : IconButton.filled(
                                      key: const Key('chat_send'),
                                      tooltip: 'Send message',
                                      onPressed: _canSend ? _submit : null,
                                      icon: const Icon(Icons.arrow_upward_rounded),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      if (length >= _counterThreshold)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xs,
                            right: AppSpacing.md,
                          ),
                          child: Text(
                            '$length / ${AppConstants.maxMessageLength}',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: length >= AppConstants.maxMessageLength
                                  ? colors.error
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
