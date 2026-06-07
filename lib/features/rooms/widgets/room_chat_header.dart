import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class RoomChatHeader extends StatelessWidget {
  final String roomName;
  final int membersCount;
  final VoidCallback onRoomsMenuTap;
  final VoidCallback onUsersTap;
  final VoidCallback onUploadTap;
  final ValueChanged<String> onMenuSelect;

  const RoomChatHeader({
    super.key,
    required this.roomName,
    required this.membersCount,
    required this.onRoomsMenuTap,
    required this.onUsersTap,
    required this.onUploadTap,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        height: R.size(context, 96),
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 18),
          R.size(context, 10),
          R.size(context, 10),
          R.size(context, 10),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            InkWell(
              onTap: onRoomsMenuTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: EdgeInsets.all(R.size(context, 4)),
                child: Icon(
                  Icons.bubble_chart_rounded,
                  color: const Color(0xFF07838E),
                  size: R.size(context, 42),
                ),
              ),
            ),

            SizedBox(width: R.size(context, 26)),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: R.sp(context, 18),
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: R.size(context, 4)),
                  Text(
                    '$membersCount Members',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                      fontSize: R.sp(context, 19),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            _HeaderIcon(icon: Icons.cloud_upload_outlined, onTap: onUploadTap),

            _HeaderIcon(icon: Icons.groups_rounded, onTap: onUsersTap),

            PopupMenuButton<String>(
              onSelected: onMenuSelect,
              color: const Color(0xFFF4EDF8),
              elevation: 6,
              offset: Offset(0, R.size(context, 46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.size(context, 6)),
              ),
              itemBuilder: (context) {
                return [
                  _menuItem(context, 'favorite', 'Remove from favourite'),
                  _menuItem(context, 'welcome', 'Welcome message'),
                  _menuItem(context, 'settings', 'Settings'),
                  _menuItem(context, 'invitation', 'Room invitation'),
                  _menuItem(context, 'report', 'Report Violation'),
                  _menuItem(context, 'leave', 'Leave room'),
                ];
              },
              child: Padding(
                padding: EdgeInsets.all(R.size(context, 8)),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                  size: R.size(context, 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    BuildContext context,
    String value,
    String title,
  ) {
    return PopupMenuItem(
      value: value,
      height: R.size(context, 62),
      child: Text(
        title,
        style: TextStyle(
          fontSize: R.sp(context, 22),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: EdgeInsets.all(R.size(context, 8)),
        child: Icon(
          icon,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
          size: R.size(context, 32),
        ),
      ),
    );
  }
}
