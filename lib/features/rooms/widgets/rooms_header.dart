// import 'package:flutter/material.dart';
// import '../../../core/utils/responsive.dart';

// class RoomsHeader extends StatelessWidget {
//   final VoidCallback onAddTap;
//   final VoidCallback onSearchTap;
//   final VoidCallback onNotificationTap;
//   final VoidCallback onSettingsTap;
//   final VoidCallback onLogoutTap;

//   const RoomsHeader({
//     super.key,
//     required this.onAddTap,
//     required this.onSearchTap,
//     required this.onNotificationTap,
//     required this.onSettingsTap,
//     required this.onLogoutTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return SafeArea(
//       bottom: false,
//       child: Padding(
//         padding: EdgeInsetsDirectional.fromSTEB(
//           R.size(context, 22),
//           R.size(context, 14),
//           R.size(context, 10),
//           R.size(context, 12),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: R.size(context, 31),
//               backgroundColor: const Color(0xFFDDE7FF),
//               child: Icon(
//                 Icons.person_rounded,
//                 size: R.size(context, 33),
//                 color: colorScheme.primary,
//               ),
//             ),

//             SizedBox(width: R.size(context, 16)),

//             Expanded(
//               child: Text(
//                 'Rooms',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: colorScheme.onSurface,
//                   fontSize: R.sp(context, 36),
//                   fontWeight: FontWeight.w400,
//                   height: 1,
//                 ),
//               ),
//             ),

//             _HeaderIcon(icon: Icons.add_rounded, onTap: onAddTap),
//             _HeaderIcon(icon: Icons.search_rounded, onTap: onSearchTap),
//             _HeaderIcon(
//               icon: Icons.notifications_rounded,
//               onTap: onNotificationTap,
//             ),

//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'settings') {
//                   onSettingsTap();
//                 } else if (value == 'logout') {
//                   onLogoutTap();
//                 }
//               },
//               color: const Color(0xFFF4EDF8),
//               elevation: 6,
//               offset: Offset(0, R.size(context, 46)),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(R.size(context, 8)),
//               ),
//               itemBuilder: (context) {
//                 return [
//                   PopupMenuItem(
//                     value: 'settings',
//                     height: R.size(context, 56),
//                     child: Text(
//                       'Settings',
//                       style: TextStyle(fontSize: R.sp(context, 24)),
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'logout',
//                     height: R.size(context, 56),
//                     child: Text(
//                       'Logout',
//                       style: TextStyle(fontSize: R.sp(context, 24)),
//                     ),
//                   ),
//                 ];
//               },
//               child: Padding(
//                 padding: EdgeInsets.all(R.size(context, 8)),
//                 child: Icon(
//                   Icons.more_vert_rounded,
//                   size: R.size(context, 33),
//                   color: colorScheme.onSurface.withValues(alpha: 0.75),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _HeaderIcon extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _HeaderIcon({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(999),
//       child: Padding(
//         padding: EdgeInsets.all(R.size(context, 8)),
//         child: Icon(
//           icon,
//           size: R.size(context, 33),
//           color: colorScheme.onSurface.withValues(alpha: 0.72),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/localization/app_localizations.dart';

class RoomsHeader extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const RoomsHeader({
    super.key,
    required this.onAddTap,
    required this.onSearchTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 22),
          R.size(context, 14),
          R.size(context, 10),
          R.size(context, 12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: R.size(context, 31),
              backgroundColor: const Color(0xFFDDE7FF),
              child: Icon(
                Icons.person_rounded,
                size: R.size(context, 33),
                color: colorScheme.primary,
              ),
            ),

            SizedBox(width: R.size(context, 16)),

            Expanded(
              child: Text(
                localizations.t('rooms'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 36),
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),

            _HeaderIcon(
              icon: Icons.add_rounded,
              onTap: onAddTap,
              tooltip: localizations.t('add'),
            ),

            _HeaderIcon(
              icon: Icons.search_rounded,
              onTap: onSearchTap,
              tooltip: localizations.t('search'),
            ),

            _HeaderIcon(
              icon: Icons.notifications_rounded,
              onTap: onNotificationTap,
              tooltip: localizations.t('notifications'),
            ),

            PopupMenuButton<String>(
              tooltip: localizations.t('menu'),
              onSelected: (value) {
                if (value == 'settings') {
                  onSettingsTap();
                } else if (value == 'logout') {
                  onLogoutTap();
                }
              },
              color: const Color(0xFFF4EDF8),
              elevation: 6,
              offset: Offset(
                0,
                R.size(context, 46),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  R.size(context, 8),
                ),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'settings',
                    height: R.size(context, 56),
                    child: Text(
                      localizations.t('settings'),
                      style: TextStyle(
                        fontSize: R.sp(context, 24),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    height: R.size(context, 56),
                    child: Text(
                      localizations.t('logout'),
                      style: TextStyle(
                        fontSize: R.sp(context, 24),
                      ),
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: EdgeInsets.all(
                  R.size(context, 8),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: R.size(context, 33),
                  color: colorScheme.onSurface.withValues(
                    alpha: 0.75,
                  ),
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
  final String tooltip;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.all(
            R.size(context, 8),
          ),
          child: Icon(
            icon,
            size: R.size(context, 33),
            color: colorScheme.onSurface.withValues(
              alpha: 0.72,
            ),
          ),
        ),
      ),
    );
  }
}