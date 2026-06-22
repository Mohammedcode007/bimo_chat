import '../data/app_notification_model.dart';

class NotificationsState {
  final bool loading;
  final String? error;

  final List<AppNotificationModel>
      tweetNotifications;

  const NotificationsState({
    this.loading = false,
    this.error,
    this.tweetNotifications = const [],
  });

  int get unreadCount {
    return tweetNotifications
        .where((item) => item.isUnread)
        .length;
  }

  NotificationsState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    List<AppNotificationModel>?
        tweetNotifications,
  }) {
    return NotificationsState(
      loading:
          loading ?? this.loading,
      error:
          clearError
              ? null
              : error ?? this.error,
      tweetNotifications:
          tweetNotifications ??
          this.tweetNotifications,
    );
  }
}