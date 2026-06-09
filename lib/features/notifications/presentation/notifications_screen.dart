import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/app_notification_model.dart';
import 'widgets/notification_card.dart';
import 'widgets/notifications_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'all';

  final List<AppNotificationModel> notifications = const [
    AppNotificationModel(
      id: '1',
      type: AppNotificationType.message,
      userName: 'Mostafa',
      username: 'mostafa',
      title: 'sent you a message',
      body: 'تمام يا محمد، ابعتلي التفاصيل.',
      time: '2m',
      isUnread: true,
    ),
    AppNotificationModel(
      id: '2',
      type: AppNotificationType.friendRequest,
      userName: 'Ahmed',
      username: 'ahmed',
      title: 'sent you a friend request',
      body: 'Ahmed wants to add you as a friend.',
      time: '10m',
      isUnread: true,
    ),
    AppNotificationModel(
      id: '3',
      type: AppNotificationType.tweetLike,
      userName: 'Sara',
      username: 'sara',
      title: 'liked your post',
      body: 'Sara liked your tweet.',
      time: '25m',
      targetText: 'ده مثال لتويتة داخل Bimo مع @Mostafa و #BimoChat.',
    ),
    AppNotificationModel(
      id: '4',
      type: AppNotificationType.tweetComment,
      userName: 'Omar',
      username: 'omar',
      title: 'commented on your post',
      body: 'جامدة جدًا يا محمد 👏',
      time: '1h',
      targetText: 'Tweet with image preview #Design',
    ),
    AppNotificationModel(
      id: '5',
      type: AppNotificationType.tweetRepost,
      userName: 'Mona',
      username: 'mona',
      title: 'reposted your post',
      body: 'Mona reposted your tweet.',
      time: '3h',
      targetText: 'Video tweet preview with @Mohammed',
    ),
    AppNotificationModel(
      id: '6',
      type: AppNotificationType.mention,
      userName: 'Khaled',
      username: 'khaled',
      title: 'mentioned you',
      body: '@mohammed شوف الكلام ده #important',
      time: '5h',
      isUnread: true,
      targetText: 'Mention inside comment or tweet.',
    ),
  ];

  List<AppNotificationModel> get filteredNotifications {
    if (selectedFilter == 'unread') {
      return notifications.where((item) => item.isUnread).toList();
    }

    if (selectedFilter == 'requests') {
      return notifications
          .where((item) => item.type == AppNotificationType.friendRequest)
          .toList();
    }

    if (selectedFilter == 'tweets') {
      return notifications.where((item) {
        return item.type == AppNotificationType.tweetLike ||
            item.type == AppNotificationType.tweetComment ||
            item.type == AppNotificationType.tweetRepost ||
            item.type == AppNotificationType.mention;
      }).toList();
    }

    return notifications;
  }

  void openNotification(AppNotificationModel notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.title),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void deleteNotification(AppNotificationModel notification) {
    setState(() {
      notifications.removeWhere((item) => item.id == notification.id);
    });
  }

  void markAllRead() {
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isUnread: false);
      }
    });
  }

  void acceptFriend(AppNotificationModel notification) {
    deleteNotification(notification);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Friend request accepted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void rejectFriend(AppNotificationModel notification) {
    deleteNotification(notification);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Friend request rejected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredNotifications;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          NotificationsHeader(
            onBackTap: () => Navigator.pop(context),
            onMarkAllReadTap: markAllRead,
          ),

          SizedBox(
            height: R.size(context, 54),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 12),
                R.size(context, 8),
                R.size(context, 12),
                R.size(context, 8),
              ),
              children: [
                _FilterChip(
                  title: 'All',
                  selected: selectedFilter == 'all',
                  onTap: () => setState(() => selectedFilter = 'all'),
                ),
                _FilterChip(
                  title: 'Unread',
                  selected: selectedFilter == 'unread',
                  onTap: () => setState(() => selectedFilter = 'unread'),
                ),
                _FilterChip(
                  title: 'Requests',
                  selected: selectedFilter == 'requests',
                  onTap: () => setState(() => selectedFilter = 'requests'),
                ),
                _FilterChip(
                  title: 'Tweets',
                  selected: selectedFilter == 'tweets',
                  onTap: () => setState(() => selectedFilter = 'tweets'),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),

          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, __) {
                      return Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.35,
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      final notification = items[index];

                      return NotificationCard(
                        notification: notification,
                        onTap: () => openNotification(notification),
                        onDeleteTap: () => deleteNotification(notification),
                        onAcceptFriendTap: () => acceptFriend(notification),
                        onRejectFriendTap: () => rejectFriend(notification),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.only(end: R.size(context, 8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.size(context, 16),
            vertical: R.size(context, 8),
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF087887)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : colorScheme.onSurfaceVariant,
              fontSize: R.sp(context, 14),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
