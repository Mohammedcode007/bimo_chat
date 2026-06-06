import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/chat_message_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageBubble({super.key, required this.message});

  IconData get statusIcon {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time_rounded;
      case MessageStatus.sent:
        return Icons.check_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.seen:
        return Icons.done_all_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = message.isMe
        ? colorScheme.primary
        : colorScheme.surface;

    final textColor = message.isMe ? Colors.white : colorScheme.onSurface;

    return Align(
      alignment: message.isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(message.isMe ? 18 : 4),
            bottomEnd: Radius.circular(message.isMe ? 4 : 18),
          ),
          border: message.isMe
              ? null
              : Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MessageContent(
              message: message,
              textColor: textColor,
              isMe: message.isMe,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    statusIcon,
                    size: 15,
                    color: message.status == MessageStatus.seen
                        ? const Color(0xFF93C5FD)
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final ChatMessageModel message;
  final Color textColor;
  final bool isMe;

  const _MessageContent({
    required this.message,
    required this.textColor,
    required this.isMe,
  });

  bool get hasLocalFile =>
      message.localPath != null && message.localPath!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.text:
        return _TextMessage(text: message.text, color: textColor);

      case ChatMessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasLocalFile)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(message.localPath!),
                  width: 220,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              )
            else
              _MediaBox(
                icon: Icons.image_rounded,
                title: 'Photo',
                textColor: textColor,
              ),
            if (message.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _TextMessage(text: message.text, color: textColor),
            ],
          ],
        );

      case ChatMessageType.video:
        return _MediaBox(
          icon: Icons.play_circle_fill_rounded,
          title: message.fileName ?? 'Video',
          textColor: textColor,
        );

      case ChatMessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: textColor, size: 28),
            const SizedBox(width: 6),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: 0.45,
                minHeight: 4,
                backgroundColor: textColor.withValues(alpha: 0.22),
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.duration ?? '0:00',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );

      case ChatMessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_rounded, color: textColor, size: 26),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.fileName ?? message.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _TextMessage extends StatelessWidget {
  final String text;
  final Color color;

  const _TextMessage({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MediaBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor;

  const _MediaBox({
    required this.icon,
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 135,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 38),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
