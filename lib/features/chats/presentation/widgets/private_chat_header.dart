import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/chat_item_model.dart';

class PrivateChatHeader extends StatelessWidget {
  final ChatItemModel chat;
  final VoidCallback onProfileTap;
  final VoidCallback onCallTap;
  final ValueChanged<String> onMenuSelect;

  const PrivateChatHeader({
    super.key,
    required this.chat,
    required this.onProfileTap,
    required this.onCallTap,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        height: R.size(context, 100),
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 26),
          R.size(context, 8),
          R.size(context, 8),
          R.size(context, 8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: R.size(context, 37),
              backgroundColor: const Color(0xFFDDE7E8),
              child: chat.avatarUrl.trim().isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        chat.avatarUrl,
                        width: R.size(context, 74),
                        height: R.size(context, 74),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const SizedBox.shrink();
                        },
                      ),
                    )
                  : null,
            ),

            SizedBox(width: R.size(context, 20)),

            Expanded(
              child: Text(
                chat.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 21),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _HeaderIcon(
              icon: Icons.person_rounded,
              color: const Color(0xFF087887),
              onTap: onProfileTap,
            ),

            _HeaderIcon(
              icon: Icons.call_rounded,
              color: const Color(0xFF087887),
              onTap: onCallTap,
            ),

            PopupMenuButton<String>(
              onSelected: onMenuSelect,
              color: const Color(0xFFF4EDF8),
              offset: Offset(0, R.size(context, 44)),
              itemBuilder: (_) {
                return const [
                  PopupMenuItem(value: 'profile', child: Text('Profile')),
                  PopupMenuItem(value: 'clear', child: Text('Clear chat')),
                  PopupMenuItem(value: 'block', child: Text('Block')),
                ];
              },
              child: Padding(
                padding: EdgeInsets.all(R.size(context, 8)),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: R.size(context, 31),
                  color: colorScheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: R.size(context, 31)),
    );
  }
}
