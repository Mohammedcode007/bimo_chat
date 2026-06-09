import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;

  final VoidCallback onSend;
  final VoidCallback onPickImage;

  final VoidCallback onStartRecord;
  final VoidCallback onStopRecord;
  final VoidCallback onCancelRecord;

  final bool isRecording;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.onStartRecord,
    required this.onStopRecord,
    required this.onCancelRecord,
    required this.isRecording,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController recordingController;

  @override
  void initState() {
    super.initState();

    recordingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      lowerBound: 0.85,
      upperBound: 1.18,
    );
  }

  @override
  void didUpdateWidget(covariant ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording && !recordingController.isAnimating) {
      recordingController.repeat(reverse: true);
    }

    if (!widget.isRecording && recordingController.isAnimating) {
      recordingController.stop();
      recordingController.value = 1;
    }
  }

  @override
  void dispose() {
    recordingController.dispose();
    super.dispose();
  }

  Color outerBackground(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (theme.brightness == Brightness.dark) {
      return colorScheme.surface;
    }

    return colorScheme.surface;
  }

  Color inputBackground(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (theme.brightness == Brightness.dark) {
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);
    }

    return theme.scaffoldBackgroundColor;
  }

  Color inputBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return colorScheme.outlineVariant.withValues(alpha: 0.45);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        color: outerBackground(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: inputBackground(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: inputBorderColor(context), width: 0.8),
          ),
          child: Row(
            children: [
              if (widget.isRecording)
                _RecordingView(
                  animation: recordingController,
                  onCancel: widget.onCancelRecord,
                  onStop: widget.onStopRecord,
                )
              else ...[
                _InputIcon(
                  icon: Icons.image_rounded,
                  onTap: widget.onPickImage,
                ),

                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: colorScheme.primary,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.70,
                        ),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller,
                  builder: (context, value, _) {
                    final hasText = value.text.trim().isNotEmpty;

                    return GestureDetector(
                      onLongPressStart: (_) {
                        if (!hasText) {
                          widget.onStartRecord();
                        }
                      },
                      onLongPressEnd: (_) {
                        if (!hasText) {
                          widget.onStopRecord();
                        }
                      },
                      child: InkWell(
                        onTap: hasText ? widget.onSend : widget.onStartRecord,
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasText
                                ? Icons.send_rounded
                                : Icons.keyboard_voice_rounded,
                            color: colorScheme.onPrimary,
                            size: 21,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InputIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _InputIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: colorScheme.onSurfaceVariant),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RecordingView extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onCancel;
  final VoidCallback onStop;

  const _RecordingView({
    required this.animation,
    required this.onCancel,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          ),

          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(Icons.mic_rounded, color: colorScheme.error),
                ),
              );
            },
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Row(
              children: List.generate(18, (index) {
                final height = 8 + math.sin(index * 0.9) * 7;

                return Expanded(
                  child: Container(
                    height: height.abs() + 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: onStop,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: colorScheme.onPrimary,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
