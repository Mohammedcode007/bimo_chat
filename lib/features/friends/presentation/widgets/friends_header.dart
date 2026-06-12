import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class FriendsHeader extends StatelessWidget {
  final String username;
  final String photoUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onAddTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const FriendsHeader({
    super.key,
    required this.username,
    required this.photoUrl,
    required this.onAvatarTap,
    required this.onAddTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 22),
          R.size(context, 14),
          R.size(context, 10),
          R.size(context, 18),
        ),
        child: Row(
          children: [
   InkWell(
  onTap: onAvatarTap,
  borderRadius: BorderRadius.circular(999),
  child: CircleAvatar(
    radius: R.size(context, 32),
    backgroundColor: const Color(0xFFDDE7FF),
    backgroundImage: photoUrl.trim().isEmpty ? null : NetworkImage(photoUrl),
    child: photoUrl.trim().isEmpty
        ? Text(
            username.trim().isEmpty
                ? '?'
                : username.characters.first.toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: R.sp(context, 24),
              fontWeight: FontWeight.w900,
            ),
          )
        : null,
  ),
),
            SizedBox(width: R.size(context, 18)),

            Expanded(
              child: Text(
                'Friends',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 36),
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),

            _HeaderIcon(icon: Icons.person_add_alt_1_rounded, onTap: onAddTap),

            _HeaderIcon(
              icon: Icons.notifications_rounded,
              onTap: onNotificationTap,
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'settings') {
                  onSettingsTap();
                } else if (value == 'logout') {
                  onLogoutTap();
                }
              },
              color: const Color(0xFFF4EDF8),
              elevation: 6,
              offset: Offset(0, R.size(context, 46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.size(context, 8)),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'settings',
                    height: R.size(context, 54),
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: R.sp(context, 22)),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    height: R.size(context, 54),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: R.sp(context, 22)),
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: EdgeInsets.all(R.size(context, 8)),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: R.size(context, 32),
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
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
          size: R.size(context, 31),
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
