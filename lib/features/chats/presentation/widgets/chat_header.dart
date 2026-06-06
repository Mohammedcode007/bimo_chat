import 'package:flutter/material.dart';
import '../../data/chat_item_model.dart';

class ChatHeader extends StatelessWidget {
  final ChatItemModel chat;

  const ChatHeader({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
        bottom: 10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),

          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              chat.name.trim().isNotEmpty
                  ? chat.name.trim()[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chat.isOnline ? 'Online' : 'Last seen recently',
                  style: TextStyle(
                    color: chat.isOnline
                        ? const Color(0xFF22C55E)
                        : colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(onPressed: () {}, icon: const Icon(Icons.call_rounded)),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}
