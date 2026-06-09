import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/chat_message_model.dart';

class PrivateMessageBubble extends StatefulWidget {
  final ChatMessageModel message;
  final VoidCallback onTap;
  final VoidCallback onReply;
  final VoidCallback onVoicePlay;
  final VoidCallback? onImageTap;

  const PrivateMessageBubble({
    super.key,
    required this.message,
    required this.onTap,
    required this.onReply,
    required this.onVoicePlay,
    this.onImageTap,
  });

  @override
  State<PrivateMessageBubble> createState() => _PrivateMessageBubbleState();
}

class _PrivateMessageBubbleState extends State<PrivateMessageBubble> {
  double dragX = 0;

  void updateDrag(DragUpdateDetails details) {
    setState(() {
      dragX += details.delta.dx;
      dragX = dragX.clamp(-70, 70);
    });
  }

  void endDrag(DragEndDetails details) {
    if (dragX.abs() > 45) {
      widget.onReply();
    }

    setState(() {
      dragX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: GestureDetector(
        onTap: widget.onTap,
        onHorizontalDragUpdate: updateDrag,
        onHorizontalDragEnd: endDrag,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(dragX, 0, 0),
          margin: EdgeInsets.only(bottom: R.size(context, 14)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.58,
                ),
                padding: EdgeInsetsDirectional.fromSTEB(
                  R.size(context, 18),
                  R.size(context, 12),
                  R.size(context, 18),
                  R.size(context, 9),
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFBFE2FA)
                      : const Color(0xFFDDE7E8),
                  borderRadius: BorderRadius.circular(R.size(context, 5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (widget.message.replyTo != null)
                      _ReplyPreview(reply: widget.message.replyTo!),

                    _MessageContent(
                      message: widget.message,
                      onVoicePlay: widget.onVoicePlay,
                      onImageTap: widget.onImageTap,
                    ),

                    SizedBox(height: R.size(context, 5)),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message.time,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.45),
                            fontSize: R.sp(context, 17),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        if (widget.message.isEdited) ...[
                          SizedBox(width: R.size(context, 5)),
                          Icon(
                            Icons.edit_rounded,
                            size: R.size(context, 15),
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ],

                        if (isMe) ...[
                          SizedBox(width: R.size(context, 6)),
                          Icon(
                            Icons.check_rounded,
                            size: R.size(context, 18),
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (widget.message.reaction != null)
                PositionedDirectional(
                  bottom: R.size(context, -10),
                  end: isMe ? null : R.size(context, -8),
                  start: isMe ? R.size(context, -8) : null,
                  child: Container(
                    padding: EdgeInsets.all(R.size(context, 4)),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.message.reaction!,
                      style: TextStyle(fontSize: R.sp(context, 15)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final ChatMessageModel reply;

  const _ReplyPreview({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: R.size(context, 8)),
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 8),
        R.size(context, 6),
        R.size(context, 8),
        R.size(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(R.size(context, 4)),
        border: BorderDirectional(
          start: BorderSide(
            color: const Color(0xFF087887),
            width: R.size(context, 3),
          ),
        ),
      ),
      child: Text(
        reply.type == ChatMessageType.voice ? 'Voice Message' : reply.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.58),
          fontSize: R.sp(context, 13),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback onVoicePlay;
  final VoidCallback? onImageTap;

  const _MessageContent({
    required this.message,
    required this.onVoicePlay,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Text(
        message.text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.42),
          fontSize: R.sp(context, 18),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (message.type == ChatMessageType.voice) {
      return InkWell(
        onTap: onVoicePlay,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_note_rounded,
              color: const Color(0xFF444850),
              size: R.size(context, 31),
            ),
            SizedBox(width: R.size(context, 8)),
            Text(
              'Voice Message ',
              style: TextStyle(
                color: const Color(0xFF444850),
                fontSize: R.sp(context, 20),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Play',
              style: TextStyle(
                color: const Color(0xFF1686C3),
                fontSize: R.sp(context, 20),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (message.type == ChatMessageType.image && message.localPath != null) {
      return GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.size(context, 5)),
          child: Image.file(
            File(message.localPath!),
            width: R.size(context, 220),
            height: R.size(context, 170),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Text(
      message.text,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: Colors.black,
        fontSize: R.sp(context, 21),
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
    );
  }
}
