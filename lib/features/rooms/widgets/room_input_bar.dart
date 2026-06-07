import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class RoomInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isRecording;
  final VoidCallback onSendText;
  final VoidCallback onPickImage;
  final VoidCallback onStartRecord;
  final VoidCallback onStopRecord;
  final VoidCallback onCancelRecord;

  const RoomInputBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.onSendText,
    required this.onPickImage,
    required this.onStartRecord,
    required this.onStopRecord,
    required this.onCancelRecord,
  });

  @override
  State<RoomInputBar> createState() => _RoomInputBarState();
}

class _RoomInputBarState extends State<RoomInputBar>
    with SingleTickerProviderStateMixin {
  bool hasText = false;
  bool showEmoji = false;

  late final AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(onTextChanged);

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.85,
      upperBound: 1.16,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onTextChanged);
    pulseController.dispose();
    super.dispose();
  }

  void onTextChanged() {
    final value = widget.controller.text.trim().isNotEmpty;
    if (value == hasText) return;

    setState(() {
      hasText = value;
    });
  }

  void toggleEmoji() {
    FocusScope.of(context).unfocus();
    setState(() {
      showEmoji = !showEmoji;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: R.size(context, 62),
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 10),
              0,
              R.size(context, 8),
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: toggleEmoji,
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    size: R.size(context, 34),
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    style: TextStyle(
                      fontSize: R.sp(context, 24),
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.isRecording ? 'Recording...' : 'Message',
                      hintStyle: TextStyle(
                        fontSize: R.sp(context, 24),
                        color: colorScheme.onSurface.withValues(alpha: 0.38),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: widget.onPickImage,
                  icon: Icon(
                    Icons.attach_file_rounded,
                    size: R.size(context, 32),
                  ),
                ),

                if (hasText)
                  IconButton(
                    onPressed: widget.onSendText,
                    icon: Icon(
                      Icons.send_rounded,
                      size: R.size(context, 31),
                      color: const Color(0xFF087887),
                    ),
                  )
                else
                  GestureDetector(
                    onLongPressStart: (_) => widget.onStartRecord(),
                    onLongPressEnd: (_) => widget.onStopRecord(),
                    onTap: widget.isRecording ? widget.onStopRecord : null,
                    child: ScaleTransition(
                      scale: widget.isRecording
                          ? pulseController
                          : const AlwaysStoppedAnimation(1),
                      child: Icon(
                        Icons.mic_rounded,
                        size: R.size(context, 32),
                        color: widget.isRecording
                            ? Colors.red
                            : colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (widget.isRecording)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: R.size(context, 8)),
              color: Colors.red.withValues(alpha: 0.08),
              child: Center(
                child: Text(
                  'Recording... release to send',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: R.sp(context, 14),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          if (showEmoji)
            SizedBox(
              height: R.size(context, 260),
              child: EmojiPicker(
                textEditingController: widget.controller,
                config: const Config(),
              ),
            ),
        ],
      ),
    );
  }
}
