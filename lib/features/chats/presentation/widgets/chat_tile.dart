import 'package:flutter/material.dart';
import '../../data/chat_item_model.dart';

class ChatTile extends StatelessWidget {
  final ChatItemModel chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  bool get hasAvatar => chat.avatarUrl.trim().isNotEmpty;

  IconData get lastMessageIcon {
    switch (chat.lastMessageType) {
      case ChatLastMessageType.image:
        return Icons.image_rounded;
      case ChatLastMessageType.video:
        return Icons.videocam_rounded;
      case ChatLastMessageType.voice:
        return Icons.keyboard_voice_rounded;
      case ChatLastMessageType.file:
        return Icons.insert_drive_file_rounded;
      case ChatLastMessageType.text:
        return Icons.message_rounded;
    }
  }

  String get lastMessageText {
    if (chat.isTyping) return 'Typing...';

    switch (chat.lastMessageType) {
      case ChatLastMessageType.image:
        return chat.lastMessage.trim().isEmpty ? 'Photo' : chat.lastMessage;
      case ChatLastMessageType.video:
        return chat.lastMessage.trim().isEmpty ? 'Video' : chat.lastMessage;
      case ChatLastMessageType.voice:
        return chat.lastMessage.trim().isEmpty
            ? 'Voice message'
            : chat.lastMessage;
      case ChatLastMessageType.file:
        return chat.lastMessage.trim().isEmpty ? 'File' : chat.lastMessage;
      case ChatLastMessageType.text:
        return chat.lastMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: ClipOval(
                      child: hasAvatar
                          ? Image.network(
                              chat.avatarUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _AvatarFallback(name: chat.name);
                              },
                            )
                          : _AvatarFallback(name: chat.name),
                    ),
                  ),

                  if (chat.isOnline)
                    PositionedDirectional(
                      end: 1,
                      bottom: 2,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chat.time,
                          style: TextStyle(
                            color: chat.unreadCount > 0
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        if (!chat.isTyping &&
                            chat.lastMessageType !=
                                ChatLastMessageType.text) ...[
                          Icon(
                            lastMessageIcon,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                        ],

                        Expanded(
                          child: Text(
                            lastMessageText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: chat.isTyping
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontSize: 13.5,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),

                        if (chat.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              chat.unreadCount > 99
                                  ? '99+'
                                  : chat.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cleanName = name.trim();
    final letter = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : '?';

    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      color: colorScheme.primary.withValues(alpha: 0.12),
      child: Text(
        letter,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
