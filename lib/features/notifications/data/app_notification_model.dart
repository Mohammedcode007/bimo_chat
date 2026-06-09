enum AppNotificationType {
  message,
  friendRequest,
  tweetLike,
  tweetComment,
  tweetRepost,
  mention,
}

class AppNotificationModel {
  final String id;
  final AppNotificationType type;

  final String userName;
  final String username;
  final String avatarUrl;

  final String title;
  final String body;
  final String time;

  final bool isUnread;
  final String? targetText;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.userName,
    required this.username,
    this.avatarUrl = '',
    required this.title,
    required this.body,
    required this.time,
    this.isUnread = false,
    this.targetText,
  });

  AppNotificationModel copyWith({
    String? id,
    AppNotificationType? type,
    String? userName,
    String? username,
    String? avatarUrl,
    String? title,
    String? body,
    String? time,
    bool? isUnread,
    String? targetText,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      userName: userName ?? this.userName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      isUnread: isUnread ?? this.isUnread,
      targetText: targetText ?? this.targetText,
    );
  }
}
