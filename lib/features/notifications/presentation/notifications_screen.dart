import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../users/logic/users_provider.dart';
import '../../users/presentation/public_profile_screen.dart';
import '../data/app_notification_model.dart';
import 'widgets/notification_card.dart';
import 'widgets/notifications_header.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String selectedFilter = 'all';

  final List<AppNotificationModel> localNotifications = [
    const AppNotificationModel(
      id: '1',
      type: AppNotificationType.message,
      userName: 'Mostafa',
      username: 'mostafa',
      title: 'sent you a message',
      body: 'تمام يا محمد، ابعتلي التفاصيل.',
      time: '2m',
      isUnread: true,
    ),
    const AppNotificationModel(
      id: '3',
      type: AppNotificationType.tweetLike,
      userName: 'Sara',
      username: 'sara',
      title: 'liked your post',
      body: 'Sara liked your tweet.',
      time: '25m',
      targetText: 'ده مثال لتويتة داخل Bimo مع @Mostafa و #BimoChat.',
    ),
    const AppNotificationModel(
      id: '4',
      type: AppNotificationType.tweetComment,
      userName: 'Omar',
      username: 'omar',
      title: 'commented on your post',
      body: 'جامدة جدًا يا محمد 👏',
      time: '1h',
      targetText: 'Tweet with image preview #Design',
    ),
    const AppNotificationModel(
      id: '5',
      type: AppNotificationType.tweetRepost,
      userName: 'Mona',
      username: 'mona',
      title: 'reposted your post',
      body: 'Mona reposted your tweet.',
      time: '3h',
      targetText: 'Video tweet preview with @Mohammed',
    ),
    const AppNotificationModel(
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

  List<AppNotificationModel> friendRequestNotifications(
    List<Map<String, dynamic>> requests,
  ) {
    return requests.map((request) {
      final fromUser = request['fromUser'] is Map
          ? Map<String, dynamic>.from(request['fromUser'])
          : <String, dynamic>{};

      final requestId = request['requestId']?.toString() ?? '';
      final username = fromUser['username']?.toString() ?? 'User';

      return AppNotificationModel(
        id: requestId,
        type: AppNotificationType.friendRequest,
        userName: username,
        username: username,
        title: 'sent you a friend request',
        body: '$username wants to add you as a friend.',
        time: 'now',
        isUnread: true,
      );
    }).toList();
  }

  List<AppNotificationModel> allNotifications(
    List<Map<String, dynamic>> incomingRequests,
  ) {
    return [
      ...friendRequestNotifications(incomingRequests),
      ...localNotifications,
    ];
  }

  List<AppNotificationModel> filteredNotifications(
    List<Map<String, dynamic>> incomingRequests,
  ) {
    final notifications = allNotifications(incomingRequests);

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

  Map<String, dynamic>? findRequestById(String requestId) {
    final requests = ref.read(usersProvider).incomingFriendRequests;

    for (final request in requests) {
      if (request['requestId']?.toString() == requestId) {
        return request;
      }
    }

    return null;
  }

  void openNotification(AppNotificationModel notification) {
    if (notification.type == AppNotificationType.friendRequest) {
      final request = findRequestById(notification.id);

      if (request == null) return;

      final fromUser = request['fromUser'] is Map
          ? Map<String, dynamic>.from(request['fromUser'])
          : <String, dynamic>{};

      final userId = fromUser['userId']?.toString() ?? '';

      if (userId.isEmpty) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicProfileScreen(userId: userId),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.title),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void deleteNotification(AppNotificationModel notification) {
    if (notification.type == AppNotificationType.friendRequest) {
      final request = findRequestById(notification.id);

      if (request != null) {
        ref.read(usersProvider.notifier).respondFriendRequest(
              requestId: notification.id,
              action: 'reject',
            );
      }

      return;
    }

    setState(() {
      localNotifications.removeWhere((item) => item.id == notification.id);
    });
  }

  void markAllRead() {
    setState(() {
      for (var i = 0; i < localNotifications.length; i++) {
        localNotifications[i] =
            localNotifications[i].copyWith(isUnread: false);
      }
    });
  }

  void acceptFriend(AppNotificationModel notification) {
    ref.read(usersProvider.notifier).respondFriendRequest(
          requestId: notification.id,
          action: 'accept',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Friend request accepted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void rejectFriend(AppNotificationModel notification) {
    ref.read(usersProvider.notifier).respondFriendRequest(
          requestId: notification.id,
          action: 'reject',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Friend request rejected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final incomingRequests = usersState.incomingFriendRequests;
    final items = filteredNotifications(incomingRequests);

    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(usersProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );

        ref.read(usersProvider.notifier).clearError();
      }
    });

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

          if (usersState.loading)
            const LinearProgressIndicator(),

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