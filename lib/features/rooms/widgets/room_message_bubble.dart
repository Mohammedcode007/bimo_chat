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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isMe = message.isMe;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;

    final bubbleColor = isMe
        ? const Color(0xFFDCF8C6)
        : isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.82)
            : Colors.white;

    final bubbleBorderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.35)
        : Colors.transparent;

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
                    color: bubbleColor,
                    border: Border.all(
                      color: bubbleBorderColor,
                      width: isDark ? 0.8 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.16 : 0.04,
                        ),
                        blurRadius: isDark ? 6 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      _SenderNameInside(
                        message: message,
                        colorScheme: colorScheme,
                        onLongPress: onNameLongPress,
                        alignEnd: isMe,
                      ),
                      SizedBox(height: R.size(context, 6)),
                      Container(
                        width: double.infinity,
                        height: R.size(context, 1),
                        color: colorScheme.onSurface.withValues(
                          alpha: isDark ? 0.18 : 0.13,
                        ),
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

  bool get hasBadge {
    final badge = message.sender.badge;
    return badge != null && badge.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final fallbackNameColor = colorScheme.onSurface.withValues(alpha: 0.92);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (alignEnd && hasBadge) ...[
            Text(
              message.sender.badge!,
              style: TextStyle(fontSize: R.sp(context, 15), height: 1),
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
                color: message.sender.nameColor ?? fallbackNameColor,
                fontSize: R.sp(context, 18),
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
          if (!alignEnd && hasBadge) ...[
            SizedBox(width: R.size(context, 5)),
            Text(
              message.sender.badge!,
              style: TextStyle(fontSize: R.sp(context, 15), height: 1),
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
        message.localPath != null &&
        message.localPath!.trim().isNotEmpty) {
      return GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.size(context, 14)),
          child: _ChatImage(
            path: message.localPath!,
            width: R.size(context, 220),
            height: R.size(context, 180),
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
                  color: colorScheme.onSurface.withValues(alpha: 0.92),
                  fontSize: R.sp(context, 18),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (message.duration != null &&
                message.duration!.trim().isNotEmpty) ...[
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
        color: colorScheme.onSurface.withValues(alpha: 0.90),
        fontSize: R.sp(context, 22),
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ChatImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const _ChatImage({
    required this.path,
    required this.width,
    required this.height,
  });

  bool get isNetwork {
    final value = path.trim().toLowerCase();
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _ImageErrorBox(width: width, height: height);
        },
      );
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _ImageErrorBox(width: width, height: height);
      },
    );
  }
}

class _ImageErrorBox extends StatelessWidget {
  final double width;
  final double height;

  const _ImageErrorBox({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_rounded,
        color: colorScheme.onSurfaceVariant,
        size: R.size(context, 34),
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

  const _AvatarWithFrame({required this.message});

  bool get hasAvatar {
    return message.sender.avatarUrl.trim().isNotEmpty;
  }

  bool get hasFrame {
    final frame = message.sender.frame;
    return frame != null && frame.trim().isNotEmpty;
  }

  bool get hasBadge {
    final badge = message.sender.badge;
    return badge != null && badge.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final frameColor = message.sender.frame == 'gold'
        ? const Color(0xFFFFC107)
        : message.sender.frame == 'blue'
            ? const Color(0xFF3B82F6)
            : message.sender.frame == 'purple'
                ? const Color(0xFF7C3AED)
                : colorScheme.error;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(hasFrame ? R.size(context, 3) : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: hasFrame
                ? Border.all(color: frameColor, width: R.size(context, 2))
                : null,
          ),
          child: CircleAvatar(
            radius: R.size(context, 31),
            backgroundColor: colorScheme.primary.withValues(alpha: 0.95),
            backgroundImage: hasAvatar
                ? NetworkImage(message.sender.avatarUrl.trim())
                : null,
            onBackgroundImageError: hasAvatar
                ? (_, __) {
                    debugPrint('Avatar image failed: ${message.sender.avatarUrl}');
                  }
                : null,
            child: hasAvatar
                ? null
                : Text(
                    message.sender.avatarText,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: R.sp(context, 18),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        if (hasBadge)
          PositionedDirectional(
            end: R.size(context, -2),
            bottom: R.size(context, -2),
            child: Container(
              width: R.size(context, 22),
              height: R.size(context, 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: R.size(context, 1),
                ),
              ),
              child: Text(
                message.sender.badge!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(context, 12),
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final RoomChatMessageModel message;

  const _SystemMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = message.systemColor ?? colorScheme.error;

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
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(R.size(context, 999)),
            border: Border.all(color: color.withValues(alpha: 0.30)),
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