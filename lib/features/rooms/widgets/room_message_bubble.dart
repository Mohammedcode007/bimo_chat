import 'dart:io';

import 'package:bimo_chat/features/rooms/data/room_chat_message_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class RoomMessageBubble extends StatelessWidget {
  final RoomChatMessageModel message;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoicePlay;
  final VoidCallback? onNameLongPress;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onAvatarLongPress;

  const RoomMessageBubble({
    super.key,
    required this.message,
    this.onImageTap,
    this.onVoicePlay,
    this.onNameLongPress,
    this.onAvatarTap,
    this.onAvatarLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == RoomChatMessageType.system) {
      return _SystemMessageBubble(message: message);
    }

    final isMe = message.isMe;
    final colorScheme = Theme.of(context).colorScheme;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 10),
        R.size(context, 7),
        R.size(context, 10),
        R.size(context, 7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _AvatarSide(
              message: message,
              onTap: onAvatarTap,
              onLongPress: onAvatarLongPress,
            ),
            SizedBox(width: R.size(context, 8)),
          ],

          Flexible(
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: R.size(context, 86),
                  maxWidth: maxBubbleWidth,
                ),
                child: Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    R.size(context, 18),
                    R.size(context, 11),
                    R.size(context, 18),
                    R.size(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(
                        isMe ? R.size(context, 18) : R.size(context, 4),
                      ),
                      topEnd: Radius.circular(
                        isMe ? R.size(context, 4) : R.size(context, 18),
                      ),
                      bottomStart: Radius.circular(R.size(context, 18)),
                      bottomEnd: Radius.circular(R.size(context, 18)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: isMe
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: _SenderNameInside(
                          message: message,
                          colorScheme: colorScheme,
                          onLongPress: onNameLongPress,
                          alignEnd: isMe,
                        ),
                      ),

                      SizedBox(height: R.size(context, 6)),

                      Container(
                        width: double.infinity,
                        height: R.size(context, 1),
                        color: colorScheme.onSurface.withValues(alpha: 0.13),
                      ),

                      SizedBox(height: R.size(context, 8)),

                      _MessageContent(
                        message: message,
                        colorScheme: colorScheme,
                        onImageTap: onImageTap,
                        onVoicePlay: onVoicePlay,
                        alignEnd: isMe,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (isMe) ...[
            SizedBox(width: R.size(context, 8)),
            _AvatarSide(
              message: message,
              isMe: true,
              onTap: onAvatarTap,
              onLongPress: onAvatarLongPress,
            ),
          ],
        ],
      ),
    );
  }
}

class _SenderNameInside extends StatelessWidget {
  final RoomChatMessageModel message;
  final ColorScheme colorScheme;
  final VoidCallback? onLongPress;
  final bool alignEnd;

  const _SenderNameInside({
    required this.message,
    required this.colorScheme,
    required this.onLongPress,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (alignEnd && message.sender.badge != null) ...[
            Text(
              message.sender.badge!,
              style: TextStyle(
                fontSize: R.sp(context, 15),
                height: 1,
              ),
            ),
            SizedBox(width: R.size(context, 5)),
          ],

          Flexible(
            child: Text(
              message.sender.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: alignEnd ? TextAlign.end : TextAlign.start,
              style: TextStyle(
                color: message.sender.nameColor ??
                    colorScheme.onSurface.withValues(alpha: 0.82),
                fontSize: R.sp(context, 18),
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),

          if (!alignEnd && message.sender.badge != null) ...[
            SizedBox(width: R.size(context, 5)),
            Text(
              message.sender.badge!,
              style: TextStyle(
                fontSize: R.sp(context, 15),
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final RoomChatMessageModel message;
  final ColorScheme colorScheme;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoicePlay;
  final bool alignEnd;

  const _MessageContent({
    required this.message,
    required this.colorScheme,
    required this.onImageTap,
    required this.onVoicePlay,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == RoomChatMessageType.image &&
        message.localPath != null) {
      return GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.size(context, 14)),
          child: Image.file(
            File(message.localPath!),
            width: R.size(context, 220),
            height: R.size(context, 180),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (message.type == RoomChatMessageType.voice) {
      return InkWell(
        onTap: onVoicePlay,
        borderRadius: BorderRadius.circular(R.size(context, 18)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              size: R.size(context, 32),
              color: const Color(0xFF087887),
            ),

            SizedBox(width: R.size(context, 8)),

            Flexible(
              child: Text(
                'Voice message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.82),
                  fontSize: R.sp(context, 18),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            if (message.duration != null) ...[
              SizedBox(width: R.size(context, 8)),
              Text(
                message.duration!,
                style: TextStyle(
                  fontSize: R.sp(context, 13),
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Text(
      message.text,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      softWrap: true,
      style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        fontSize: R.sp(context, 22),
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _AvatarSide extends StatelessWidget {
  final RoomChatMessageModel message;
  final bool isMe;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AvatarSide({
    required this.message,
    this.isMe = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: R.size(context, 72),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: _AvatarWithFrame(message: message),
            ),
          ),

          if (message.roleStarColor != Colors.transparent)
            PositionedDirectional(
              top: R.size(context, -3),
              start: R.size(context, 3),
              child: IgnorePointer(
                child: Icon(
                  Icons.star_rounded,
                  color: message.roleStarColor,
                  size: R.size(context, 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarWithFrame extends StatelessWidget {
  final RoomChatMessageModel message;

  const _AvatarWithFrame({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final hasFrame = message.sender.frame != null;

    return Container(
      padding: EdgeInsets.all(
        hasFrame ? R.size(context, 3) : 0,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasFrame
            ? Border.all(
                color: message.sender.frame == 'gold'
                    ? const Color(0xFFFFC107)
                    : Colors.red,
                width: R.size(context, 2),
              )
            : null,
      ),
      child: CircleAvatar(
        radius: R.size(context, 31),
        backgroundColor: const Color(0xFF0C3A3F),
        child: Text(
          message.sender.avatarText,
          style: TextStyle(
            color: Colors.white,
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final RoomChatMessageModel message;

  const _SystemMessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = message.systemColor ?? Colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 24),
        vertical: R.size(context, 8),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.size(context, 16),
            vertical: R.size(context, 8),
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(R.size(context, 999)),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            message.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: R.sp(context, 14),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}