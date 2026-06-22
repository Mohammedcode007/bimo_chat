// enum AppNotificationType {
//   message,
//   friendRequest,
//   tweetLike,
//   tweetComment,
//   tweetRepost,
//   mention,
// }

// class AppNotificationModel {
//   final String id;
//   final AppNotificationType type;

//   final String userName;
//   final String username;
//   final String avatarUrl;

//   final String title;
//   final String body;
//   final String time;

//   final bool isUnread;
//   final String? targetText;

//   const AppNotificationModel({
//     required this.id,
//     required this.type,
//     required this.userName,
//     required this.username,
//     this.avatarUrl = '',
//     required this.title,
//     required this.body,
//     required this.time,
//     this.isUnread = false,
//     this.targetText,
//   });

//   AppNotificationModel copyWith({
//     String? id,
//     AppNotificationType? type,
//     String? userName,
//     String? username,
//     String? avatarUrl,
//     String? title,
//     String? body,
//     String? time,
//     bool? isUnread,
//     String? targetText,
//   }) {
//     return AppNotificationModel(
//       id: id ?? this.id,
//       type: type ?? this.type,
//       userName: userName ?? this.userName,
//       username: username ?? this.username,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       title: title ?? this.title,
//       body: body ?? this.body,
//       time: time ?? this.time,
//       isUnread: isUnread ?? this.isUnread,
//       targetText: targetText ?? this.targetText,
//     );
//   }
// }


enum AppNotificationType {
  message,
  friendRequest,

  tweetLike,
  tweetComment,
  tweetRepost,

  /*
    منشن داخل التويتة نفسها.
  */
  tweetMention,

  /*
    منشن داخل تعليق.
  */
  commentMention,

  /*
    للتوافق مع الكود القديم الذي يستخدم mention.
  */
  mention,
}

class AppNotificationModel {
  final String id;
  final AppNotificationType type;

  /*
    بيانات المستخدم الذي أرسل الإشعار.
  */
  final String senderUserId;
  final String userName;
  final String username;
  final String avatarUrl;

  final String title;
  final String body;
  final String time;

  final bool isUnread;
  final String? targetText;

  /*
    بيانات التويتة المرتبطة بالإشعار.
    تبقى فارغة في طلبات الصداقة والرسائل.
  */
  final String tweetId;
  final String commentId;

  final DateTime? createdAt;

  const AppNotificationModel({
    required this.id,
    required this.type,

    this.senderUserId = '',

    required this.userName,
    required this.username,

    this.avatarUrl = '',

    required this.title,
    required this.body,
    required this.time,

    this.isUnread = false,
    this.targetText,

    this.tweetId = '',
    this.commentId = '',

    this.createdAt,
  });

  /*
    تحويل بيانات الباك إلى موديل الفرونت.

    يدعم شكل الإشعار المباشر:
    {
      handler: notification_event,
      type: new,
      notification: {...}
    }

    كما يدعم عناصر notifications.list.
  */
  factory AppNotificationModel.fromMap(
    Map<String, dynamic> source,
  ) {
    final map =
        source['notification'] is Map
            ? Map<String, dynamic>.from(
                source['notification'] as Map,
              )
            : Map<String, dynamic>.from(
                source,
              );

    final metadata =
        map['metadata'] is Map
            ? Map<String, dynamic>.from(
                map['metadata'] as Map,
              )
            : map['data'] is Map
                ? Map<String, dynamic>.from(
                    map['data'] as Map,
                  )
                : <String, dynamic>{};

    String readString(
      dynamic value,
    ) {
      return value?.toString().trim() ?? '';
    }

    bool readBool(
      dynamic value, {
      bool fallback = false,
    }) {
      if (value is bool) {
        return value;
      }

      final text =
          readString(value).toLowerCase();

      if (text == 'true' || text == '1') {
        return true;
      }

      if (text == 'false' || text == '0') {
        return false;
      }

      return fallback;
    }

    final rawType =
        readString(
          map['notificationType'] ??
              map['type'] ??
              metadata['notificationType'],
        ).toLowerCase();

    final createdAt =
        DateTime.tryParse(
          readString(
            map['createdAt'] ??
                map['created_at'],
          ),
        );

    final senderUsername =
        readString(
          map['senderUsername'] ??
              map['username'] ??
              metadata['senderUsername'],
        );

    return AppNotificationModel(
      id: readString(
        map['notificationId'] ??
            map['notification_id'] ??
            map['id'] ??
            map['_id'],
      ),

      type: typeFromServer(
        rawType,
      ),

      senderUserId: readString(
        map['senderUserId'] ??
            map['fromUserId'] ??
            metadata['senderUserId'],
      ),

      userName:
          senderUsername.isNotEmpty
              ? senderUsername
              : 'User',

      username:
          senderUsername.isNotEmpty
              ? senderUsername
              : 'user',

      avatarUrl: readString(
        map['senderPhotoUrl'] ??
            map['photoUrl'] ??
            map['avatarUrl'] ??
            metadata['senderPhotoUrl'],
      ),

      title: readString(
        map['title'],
      ).isNotEmpty
          ? readString(
              map['title'],
            )
          : titleFromServerType(
              rawType,
            ),

      body: readString(
        map['body'] ??
            map['message'] ??
            map['text'],
      ),

      time: formatNotificationTime(
        createdAt,
      ),

      /*
        كل إشعار ما زال موجودًا في الباك يعتبر غير مفتوح؛
        لأن الباك يحذفه عند فتحه.
      */
      isUnread: !readBool(
        map['isRead'] ??
            map['read'],
        fallback: false,
      ),

      targetText: readString(
        map['targetText'] ??
            map['target_text'] ??
            metadata['targetText'],
      ).isEmpty
          ? null
          : readString(
              map['targetText'] ??
                  map['target_text'] ??
                  metadata['targetText'],
            ),

      tweetId: readString(
        map['tweetId'] ??
            map['relatedTweet'] ??
            map['relatedTweetId'] ??
            metadata['tweetId'],
      ),

      commentId: readString(
        map['commentId'] ??
            map['relatedMessage'] ??
            map['relatedCommentId'] ??
            metadata['commentId'],
      ),

      createdAt: createdAt,
    );
  }

  static AppNotificationType typeFromServer(
    String value,
  ) {
    switch (value.trim().toLowerCase()) {
      case 'tweet_like':
        return AppNotificationType.tweetLike;

      case 'tweet_comment':
        return AppNotificationType.tweetComment;

      case 'tweet_retweet':
        return AppNotificationType.tweetRepost;

      case 'tweet_mention':
        return AppNotificationType.tweetMention;

      case 'comment_mention':
        return AppNotificationType.commentMention;

      case 'friend_request':
      case 'friendrequest':
        return AppNotificationType.friendRequest;

      case 'message':
      case 'dm_message':
        return AppNotificationType.message;

      case 'mention':
        return AppNotificationType.mention;

      default:
        return AppNotificationType.mention;
    }
  }

  static String titleFromServerType(
    String value,
  ) {
    switch (value.trim().toLowerCase()) {
      case 'tweet_like':
        return 'liked your post';

      case 'tweet_comment':
        return 'commented on your post';

      case 'tweet_retweet':
        return 'reposted your post';

      case 'tweet_mention':
        return 'mentioned you in a tweet';

      case 'comment_mention':
        return 'mentioned you in a comment';

      case 'friend_request':
        return 'sent you a friend request';

      case 'message':
      case 'dm_message':
        return 'sent you a message';

      default:
        return 'new notification';
    }
  }

  static String formatNotificationTime(
    DateTime? date,
  ) {
    if (date == null) {
      return 'now';
    }

    final now =
        DateTime.now();

    final localDate =
        date.toLocal();

    final difference =
        now.difference(
      localDate,
    );

    if (difference.isNegative ||
        difference.inSeconds < 60) {
      return 'now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    return '${difference.inDays}d';
  }

  bool get isTweetNotification {
    return type ==
            AppNotificationType.tweetLike ||
        type ==
            AppNotificationType.tweetComment ||
        type ==
            AppNotificationType.tweetRepost ||
        type ==
            AppNotificationType.tweetMention ||
        type ==
            AppNotificationType.commentMention ||
        type ==
            AppNotificationType.mention;
  }

  bool get isFriendRequest {
    return type ==
        AppNotificationType.friendRequest;
  }

  AppNotificationModel copyWith({
    String? id,
    AppNotificationType? type,

    String? senderUserId,

    String? userName,
    String? username,
    String? avatarUrl,

    String? title,
    String? body,
    String? time,

    bool? isUnread,
    String? targetText,

    String? tweetId,
    String? commentId,

    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id:
          id ?? this.id,

      type:
          type ?? this.type,

      senderUserId:
          senderUserId ??
          this.senderUserId,

      userName:
          userName ??
          this.userName,

      username:
          username ??
          this.username,

      avatarUrl:
          avatarUrl ??
          this.avatarUrl,

      title:
          title ??
          this.title,

      body:
          body ??
          this.body,

      time:
          time ??
          this.time,

      isUnread:
          isUnread ??
          this.isUnread,

      targetText:
          targetText ??
          this.targetText,

      tweetId:
          tweetId ??
          this.tweetId,

      commentId:
          commentId ??
          this.commentId,

      createdAt:
          createdAt ??
          this.createdAt,
    );
  }
}