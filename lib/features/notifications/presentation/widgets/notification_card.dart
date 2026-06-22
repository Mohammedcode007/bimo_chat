import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/app_notification_model.dart';

class NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onAcceptFriendTap;
  final VoidCallback? onRejectFriendTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDeleteTap,
    this.onAcceptFriendTap,
    this.onRejectFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreadColor = const Color(0xFF087887).withValues(alpha: 0.08);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isUnread
            ? unreadColor
            : Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 14),
          R.size(context, 12),
          R.size(context, 10),
          R.size(context, 12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _Avatar(notification: notification),

                PositionedDirectional(
                  end: R.size(context, -4),
                  bottom: R.size(context, -2),
                  child: _TypeIcon(type: notification.type),
                ),
              ],
            ),

            SizedBox(width: R.size(context, 13)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleLine(notification: notification),

                  SizedBox(height: R.size(context, 4)),

                  Text(
                    notification.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.82),
                      fontSize: R.sp(context, 16),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),

                  if (notification.targetText != null &&
                      notification.targetText!.trim().isNotEmpty) ...[
                    SizedBox(height: R.size(context, 8)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        R.size(context, 10),
                        R.size(context, 8),
                        R.size(context, 10),
                        R.size(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(
                          R.size(context, 12),
                        ),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      child: Text(
                        notification.targetText!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: _isArabic(notification.targetText!)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 14),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],

                  if (notification.type == AppNotificationType.friendRequest)
                    Padding(
                      padding: EdgeInsets.only(top: R.size(context, 10)),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: onAcceptFriendTap,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF087887),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: R.size(context, 18),
                                vertical: R.size(context, 8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  R.size(context, 999),
                                ),
                              ),
                            ),
                            child: Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: R.sp(context, 14),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          SizedBox(width: R.size(context, 8)),

                          OutlinedButton(
                            onPressed: onRejectFriendTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.onSurface,
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: R.size(context, 18),
                                vertical: R.size(context, 8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  R.size(context, 999),
                                ),
                              ),
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: R.sp(context, 14),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Column(
              children: [
                Text(
                  notification.time,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: R.sp(context, 13),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: R.size(context, 4)),

                PopupMenuButton<String>(
                  color: colorScheme.surface,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: R.size(context, 22),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDeleteTap();
                    }
                  },
                  itemBuilder: (_) {
                    return const [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}

class _TitleLine extends StatelessWidget {
  final AppNotificationModel notification;

  const _TitleLine({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: notification.userName,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: R.sp(context, 16.5),
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          TextSpan(
            text: ' ${notification.title}',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: R.sp(context, 16.5),
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppNotificationModel notification;

  const _Avatar({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: R.size(context, 25),
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: notification.avatarUrl.trim().isNotEmpty
          ? ClipOval(
              child: Image.network(
                notification.avatarUrl,
                width: R.size(context, 50),
                height: R.size(context, 50),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _AvatarText(notification: notification);
                },
              ),
            )
          : _AvatarText(notification: notification),
    );
  }
}

class _AvatarText extends StatelessWidget {
  final AppNotificationModel notification;

  const _AvatarText({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      notification.userName.isEmpty
          ? '?'
          : notification.userName[0].toUpperCase(),
      style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.75),
        fontSize: R.sp(context, 18),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final AppNotificationType type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final data = _iconData(type);

    return Container(
      width: R.size(context, 24),
      height: R.size(context, 24),
      decoration: BoxDecoration(
        color: data.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: R.size(context, 2),
        ),
      ),
      child: Icon(data.icon, color: Colors.white, size: R.size(context, 14)),
    );
  }

_NotificationIconData _iconData(
  AppNotificationType type,
) {
  switch (type) {
    case AppNotificationType.message:
      return const _NotificationIconData(
        icon: Icons.chat_bubble_rounded,
        color: Color(0xFF1D9BF0),
      );

    case AppNotificationType.friendRequest:
      return const _NotificationIconData(
        icon: Icons.person_add_rounded,
        color: Color(0xFF087887),
      );

    case AppNotificationType.tweetLike:
      return const _NotificationIconData(
        icon: Icons.favorite_rounded,
        color: Color(0xFFF91880),
      );

    case AppNotificationType.tweetComment:
      return const _NotificationIconData(
        icon: Icons.mode_comment_rounded,
        color: Color(0xFF1D9BF0),
      );

    case AppNotificationType.tweetRepost:
      return const _NotificationIconData(
        icon: Icons.repeat_rounded,
        color: Color(0xFF00BA7C),
      );

    case AppNotificationType.tweetMention:
      return const _NotificationIconData(
        icon: Icons.alternate_email_rounded,
        color: Color(0xFF8B5CF6),
      );

    case AppNotificationType.commentMention:
      return const _NotificationIconData(
        icon: Icons.alternate_email_rounded,
        color: Color(0xFFFF8A00),
      );

    case AppNotificationType.mention:
      return const _NotificationIconData(
        icon: Icons.alternate_email_rounded,
        color: Color(0xFF8B5CF6),
      );
  }
}
}

class _NotificationIconData {
  final IconData icon;
  final Color color;

  const _NotificationIconData({required this.icon, required this.color});
}
