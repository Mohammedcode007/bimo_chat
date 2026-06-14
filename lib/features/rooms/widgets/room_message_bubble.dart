import 'dart:io';

import 'package:bimo_chat/core/utils/helpers.dart';
import 'package:bimo_chat/features/rooms/data/room_chat_message_model.dart';
import 'package:bimo_chat/features/rooms/data/room_role.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

String cleanVisibleText(String input) {
  return input
      // Zero width / invisible chars
      .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F]'), '')
      // Variation selectors
      .replaceAll(RegExp(r'[\uFE00-\uFE0F]'), '')
      // Combining diacritics
      .replaceAll(RegExp(r'[\u0300-\u036F]'), '')
      .replaceAll(RegExp(r'[\u1AB0-\u1AFF]'), '')
      .replaceAll(RegExp(r'[\u1DC0-\u1DFF]'), '')
      .replaceAll(RegExp(r'[\u20D0-\u20FF]'), '')
      .replaceAll(RegExp(r'[\uFE20-\uFE2F]'), '')
      // Khmer invisible marks
      .replaceAll(RegExp(r'[\u17B4-\u17B5]'), '')
      // Meetei / extra combining marks
      .replaceAll(RegExp(r'[\uAA7B-\uAA7D]'), '')
      .trim();
}

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
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.76;

    final bubbleColor = isMe
        ? Colors.white
        : isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.82)
        : Colors.white;

    final bubbleBorderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.35)
        : colorScheme.outlineVariant.withValues(alpha: 0.18);

    final bubbleTextColor = isMe
        ? Colors.black87
        : colorScheme.onSurface.withValues(alpha: 0.92);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 8),
        R.size(context, 5),
        R.size(context, 8),
        R.size(context, 5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _AvatarSide(
              message: message,
              onTap: onAvatarTap,
              onLongPress: onAvatarLongPress,
            ),
            SizedBox(width: R.size(context, 6)),
          ],

          Flexible(
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: R.size(context, 78),
                  maxWidth: maxBubbleWidth,
                ),
                child: Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    R.size(context, 12),
                    R.size(context, 8),
                    R.size(context, 12),
                    R.size(context, 9),
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    border: Border.all(
                      color: bubbleBorderColor,
                      width: isDark ? 0.8 : 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.14 : 0.035,
                        ),
                        blurRadius: isDark ? 6 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(
                        isMe ? R.size(context, 15) : R.size(context, 4),
                      ),
                      topEnd: Radius.circular(
                        isMe ? R.size(context, 4) : R.size(context, 15),
                      ),
                      bottomStart: Radius.circular(R.size(context, 15)),
                      bottomEnd: Radius.circular(R.size(context, 15)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      _SenderNameInside(
                        message: message,
                        colorScheme: colorScheme,
                        onLongPress: onNameLongPress,
                        alignEnd: isMe,
                      ),
                      SizedBox(height: R.size(context, 5)),
                      _MessageContent(
                        message: message,
                        colorScheme: colorScheme,
                        textColor: bubbleTextColor,
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
            SizedBox(width: R.size(context, 6)),
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

  String roleStar() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return '★';
    if (role == RoomRole.admin) return '★';

    return '';
  }

  Color roleStarColor() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return Colors.red;
    if (role == RoomRole.admin) return Colors.blue;

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final fallbackNameColor = colorScheme.onSurface.withValues(alpha: 0.92);
    final star = roleStar();
    final starColor = roleStarColor();
    final badge = hasBadge ? message.sender.badge!.trim() : '';

final nameStyle = TextStyle(
  color: message.sender.nameColor ?? fallbackNameColor,
  fontSize: R.sp(context, 19),
  fontWeight: FontWeight.w800,
  height: 1.08,
  letterSpacing: -0.2,
  fontFamily: null,
  fontFamilyFallback: const [
    'Roboto',
    'Noto Sans',
    'Noto Sans Symbols',
    'Noto Sans Symbols 2',
    'Noto Color Emoji',
    'Segoe UI Emoji',
  ],
);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: alignEnd
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignEnd
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: cleanVisibleText(message.sender.name),
                    style: nameStyle,
                  ),
                  if (badge.isNotEmpty)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: R.size(context, 5),
                        ),
                        child: Text(
                          badge,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: R.sp(context, 15),
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (star.isNotEmpty)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: R.size(context, 5),
                        ),
                        child: Text(
                          star,
                          style: TextStyle(
                            color: starColor,
                            fontSize: R.sp(context, 15),
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              textAlign: alignEnd ? TextAlign.end : TextAlign.start,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),

            SizedBox(height: R.size(context, 4)),

            Container(
              height: R.size(context, 1),
              width: double.infinity,
              color: colorScheme.onSurface.withValues(alpha: 0.13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final RoomChatMessageModel message;
  final ColorScheme colorScheme;
  final Color textColor;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoicePlay;
  final bool alignEnd;

  const _MessageContent({
    required this.message,
    required this.colorScheme,
    required this.textColor,
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
          borderRadius: BorderRadius.circular(R.size(context, 12)),
          child:_ChatImage(
  path: message.localPath!,
  width: MediaQuery.sizeOf(context).width * 0.62,
  height: R.size(context, 220),
),
        ),
      );
    }

    if (message.type == RoomChatMessageType.voice) {
      return InkWell(
        onTap: onVoicePlay,
        borderRadius: BorderRadius.circular(R.size(context, 16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              size: R.size(context, 30),
              color: const Color(0xFF087887),
            ),
            SizedBox(width: R.size(context, 7)),
            Flexible(
              child: Text(
                'Voice message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: R.sp(context, 17),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (message.duration != null &&
                message.duration!.trim().isNotEmpty) ...[
              SizedBox(width: R.size(context, 7)),
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
  cleanVisibleText(message.text),
  textAlign: alignEnd ? TextAlign.end : TextAlign.start,
  softWrap: true,
  style: TextStyle(
    color: textColor,
    fontSize: R.sp(context, 22),
    height: 1.35,
    fontWeight: FontWeight.w600,
    fontFamily: null,
    fontFamilyFallback: const [
      'Roboto',
      'Noto Sans',
      'Noto Sans Symbols',
      'Noto Sans Symbols 2',
      'Noto Color Emoji',
      'Segoe UI Emoji',
    ],
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
  gaplessPlayback: true,
  filterQuality: FilterQuality.medium,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;

    return SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  },
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

  const _ImageErrorBox({required this.width, required this.height});

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
        size: R.size(context, 32),
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

  String roleStar() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return '★';
    if (role == RoomRole.admin) return '★';

    return '';
  }

  Color roleStarColor() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return Colors.red;
    if (role == RoomRole.admin) return Colors.blue;

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final star = roleStar();
    final starColor = roleStarColor();

    return SizedBox(
      width: R.size(context, 78),
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
          if (star.isNotEmpty)
            PositionedDirectional(
              top: R.size(context, -5),
              end: R.size(context, -1),
              child: IgnorePointer(
                child: Text(
                  star,
                  style: TextStyle(
                    color: starColor,
                    fontSize: R.sp(context, 15),
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
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

    return Container(
      padding: EdgeInsets.all(hasFrame ? R.size(context, 2.2) : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasFrame
            ? Border.all(color: frameColor, width: R.size(context, 1.5))
            : null,
      ),
      child: CircleAvatar(
        radius: R.size(context, 36),
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
                  fontSize: R.sp(context, 14),
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
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
