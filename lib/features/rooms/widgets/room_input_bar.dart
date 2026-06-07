import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

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
  final FocusNode inputFocusNode = FocusNode();

  bool hasText = false;
  bool showEmoji = false;

  late final AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(onTextChanged);
    inputFocusNode.addListener(onInputFocusChanged);

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
    inputFocusNode.removeListener(onInputFocusChanged);
    inputFocusNode.dispose();
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

  void onInputFocusChanged() {
    if (inputFocusNode.hasFocus && showEmoji) {
      setState(() {
        showEmoji = false;
      });
    }
  }

  void openKeyboard() {
    if (showEmoji) {
      setState(() {
        showEmoji = false;
      });
    }

    FocusScope.of(context).requestFocus(inputFocusNode);
  }

  Future<void> toggleEmoji() async {
    if (showEmoji) {
      setState(() {
        showEmoji = false;
      });

      FocusScope.of(context).requestFocus(inputFocusNode);
      return;
    }

    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    setState(() {
      showEmoji = true;
    });
  }

  void sendText() {
    if (!hasText) return;

    widget.onSendText();

    setState(() {
      showEmoji = false;
    });
  }

  double emojiHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    if (bottomInset > 0) {
      return bottomInset;
    }

    final height = screenHeight * 0.36;

    return height.clamp(R.size(context, 260), R.size(context, 340));
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
            constraints: BoxConstraints(minHeight: R.size(context, 62)),
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 10),
              R.size(context, 4),
              R.size(context, 8),
              R.size(context, 4),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: toggleEmoji,
                  icon: Icon(
                    showEmoji
                        ? Icons.keyboard_alt_outlined
                        : Icons.emoji_emotions_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    size: R.size(context, 34),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: openKeyboard,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: inputFocusNode,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        fontSize: R.sp(context, 22),
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isRecording
                            ? 'Recording...'
                            : 'Message',
                        hintStyle: TextStyle(
                          fontSize: R.sp(context, 22),
                          color: colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: R.size(context, 10),
                        ),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: widget.onPickImage,
                  icon: Icon(
                    Icons.attach_file_rounded,
                    size: R.size(context, 32),
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),

                if (hasText)
                  IconButton(
                    onPressed: sendText,
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
                    child: Padding(
                      padding: EdgeInsets.all(R.size(context, 8)),
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

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: showEmoji
                ? SizedBox(
                    key: const ValueKey('emoji_picker'),
                    height: emojiHeight(context),
                    child: EmojiPicker(
                      textEditingController: widget.controller,
                      config: Config(
                        height: emojiHeight(context),
                        emojiViewConfig: EmojiViewConfig(
                          columns: 7,
                          emojiSizeMax: R.size(context, 30),
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                        ),
                        categoryViewConfig: CategoryViewConfig(
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          indicatorColor: const Color(0xFF087887),
                          iconColor: colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                          iconColorSelected: const Color(0xFF087887),
                        ),
                        bottomActionBarConfig: const BottomActionBarConfig(
                          enabled: false,
                        ),
                        searchViewConfig: SearchViewConfig(
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('emoji_hidden')),
          ),
        ],
      ),
    );
  }
}
