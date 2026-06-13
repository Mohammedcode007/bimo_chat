import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class RoomChatHeader extends StatelessWidget {
  final String roomName;
  final int membersCount;
  final bool isFavorite;

  final VoidCallback onRoomsMenuTap;
  final VoidCallback onUsersTap;
  final VoidCallback onUploadTap;
  final ValueChanged<String> onMenuSelect;

  const RoomChatHeader({
    super.key,
    required this.roomName,
    required this.membersCount,
    this.isFavorite = false,
    required this.onRoomsMenuTap,
    required this.onUsersTap,
    required this.onUploadTap,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        height: R.size(context, 96),
        color: theme.scaffoldBackgroundColor,
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 22),
          R.size(context, 8),
          R.size(context, 10),
          R.size(context, 8),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onRoomsMenuTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: EdgeInsets.all(R.size(context, 6)),
                child: Icon(
                  Icons.bubble_chart_rounded,
                  color: const Color(0xFF087887),
                  size: R.size(context, 40),
                ),
              ),
            ),

            SizedBox(width: R.size(context, 22)),

            Expanded(
              child: InkWell(
                onTap: onRoomsMenuTap,
                borderRadius: BorderRadius.circular(R.size(context, 12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 18),
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),

                    SizedBox(height: R.size(context, 5)),

                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: const Color(0xFF087887),
                          size: R.size(context, 9),
                        ),
                        SizedBox(width: R.size(context, 6)),
                        Flexible(
                          child: Text(
                            '$membersCount Online',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: R.sp(context, 18),
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            _HeaderIcon(
              icon: Icons.cloud_upload_outlined,
              onTap: onUploadTap,
            ),

            _HeaderIcon(
              icon: Icons.groups_rounded,
              onTap: onUsersTap,
            ),

            PopupMenuButton<String>(
              onSelected: onMenuSelect,
              color: colorScheme.surface,
              elevation: theme.brightness == Brightness.dark ? 2 : 6,
              offset: Offset(0, R.size(context, 46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.size(context, 8)),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  width: 0.8,
                ),
              ),
              itemBuilder: (context) {
                return [
                  _menuItem(
                    context,
                    'favorite',
                    isFavorite ? 'Remove from favourite' : 'Add to favourite',
                  ),
                  _menuItem(context, 'welcome', 'Welcome message'),
                  _menuItem(context, 'settings', 'Settings'),
                  _menuItem(context, 'invitation', 'Room invitation'),
                  _menuItem(
                    context,
                    'report',
                    'Report Violation',
                    color: colorScheme.error,
                  ),
                  _menuItem(
                    context,
                    'leave',
                    'Leave room',
                    color: colorScheme.error,
                  ),
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
    String title, {
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuItem(
      value: value,
      height: R.size(context, 58),
      child: Text(
        title,
        style: TextStyle(
          color: color ?? colorScheme.onSurface,
          fontSize: R.sp(context, 21),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
  });

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
          size: R.size(context, 31),
        ),
      ),
    );
  }
}