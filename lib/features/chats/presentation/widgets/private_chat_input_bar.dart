import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/chat_message_model.dart';

class PrivateChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final ChatMessageModel? replyMessage;
  final ChatMessageModel? editingMessage;
  final bool isRecording;
  final VoidCallback onCancelReplyOrEdit;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onStartRecord;
  final VoidCallback onStopRecord;
  final VoidCallback onCancelRecord;

  const PrivateChatInputBar({
    super.key,
    required this.controller,
    required this.replyMessage,
    required this.editingMessage,
    required this.isRecording,
    required this.onCancelReplyOrEdit,
    required this.onSend,
    required this.onPickImage,
    required this.onStartRecord,
    required this.onStopRecord,
    required this.onCancelRecord,
  });

  @override
  State<PrivateChatInputBar> createState() => _PrivateChatInputBarState();
}

class _PrivateChatInputBarState extends State<PrivateChatInputBar>
    with SingleTickerProviderStateMixin {
  final FocusNode inputFocusNode = FocusNode();

  bool hasText = false;
  bool showEmoji = false;

  late final AnimationController recordPulseController;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(onTextChanged);
    inputFocusNode.addListener(onInputFocusChanged);

    recordPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      lowerBound: 0.86,
      upperBound: 1.15,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onTextChanged);
    inputFocusNode.removeListener(onInputFocusChanged);
    inputFocusNode.dispose();
    recordPulseController.dispose();
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

  void sendMessage() {
    if (!hasText) return;

    widget.onSend();

    setState(() {
      showEmoji = false;
    });
  }

  double emojiHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    if (keyboardHeight > 0) {
      return keyboardHeight + R.size(context, 40);
    }

    final calculatedHeight = screenHeight * 0.60;

    return calculatedHeight.clamp(R.size(context, 330), R.size(context, 430));
  }

  @override
  Widget build(BuildContext context) {
    final activePreview = widget.replyMessage ?? widget.editingMessage;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activePreview != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFEAF0F2),
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 14),
                R.size(context, 8),
                R.size(context, 14),
                R.size(context, 8),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.editingMessage != null
                        ? Icons.edit_rounded
                        : Icons.reply_rounded,
                    color: const Color(0xFF087887),
                    size: R.size(context, 24),
                  ),

                  SizedBox(width: R.size(context, 8)),

                  Expanded(
                    child: Text(
                      widget.editingMessage != null
                          ? 'Editing message'
                          : activePreview.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.65),
                        fontSize: R.sp(context, 15),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: widget.onCancelReplyOrEdit,
                    icon: Icon(Icons.close_rounded, size: R.size(context, 24)),
                  ),
                ],
              ),
            ),

          Container(
            constraints: BoxConstraints(minHeight: R.size(context, 72)),
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 10),
              R.size(context, 4),
              R.size(context, 8),
              R.size(context, 4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: toggleEmoji,
                  icon: Icon(
                    showEmoji
                        ? Icons.keyboard_alt_outlined
                        : Icons.emoji_emotions_outlined,
                    color: const Color(0xFF444850),
                    size: R.size(context, 36),
                  ),
                ),

                SizedBox(width: R.size(context, 4)),

                Expanded(
                  child: GestureDetector(
                    onTap: openKeyboard,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: inputFocusNode,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        fontSize: R.sp(context, 25),
                        color: Colors.black,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isRecording
                            ? 'Recording...'
                            : 'Message',
                        hintStyle: TextStyle(
                          fontSize: R.sp(context, 25),
                          color: Colors.black.withValues(alpha: 0.35),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: R.size(context, 13),
                        ),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: widget.onPickImage,
                  icon: Icon(
                    Icons.attach_file_rounded,
                    size: R.size(context, 35),
                    color: const Color(0xFF444850),
                  ),
                ),

                if (hasText)
                  IconButton(
                    onPressed: sendMessage,
                    icon: Icon(
                      Icons.send_rounded,
                      size: R.size(context, 32),
                      color: const Color(0xFF087887),
                    ),
                  )
                else
                  GestureDetector(
                    onLongPressStart: (_) => widget.onStartRecord(),
                    onLongPressEnd: (_) => widget.onStopRecord(),
                    child: Padding(
                      padding: EdgeInsets.all(R.size(context, 9)),
                      child: ScaleTransition(
                        scale: widget.isRecording
                            ? recordPulseController
                            : const AlwaysStoppedAnimation(1),
                        child: Icon(
                          Icons.mic_rounded,
                          size: R.size(context, 35),
                          color: widget.isRecording
                              ? Colors.red
                              : const Color(0xFF444850),
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
                    key: const ValueKey('private_emoji_picker'),
                    height: emojiHeight(context),
                    child: EmojiPicker(
                      textEditingController: widget.controller,
                      config: Config(
                        height: emojiHeight(context),
                        emojiViewConfig: EmojiViewConfig(
                          columns: 7,
                          emojiSizeMax: R.size(context, 31),
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
                : const SizedBox.shrink(key: ValueKey('private_emoji_hidden')),
          ),
        ],
      ),
    );
  }
}
