enum TweetMediaType { none, image, video }

class TweetReplyModel {
  final String id;
  final String authorName;
  final String username;
  final String avatarUrl;
  final String text;
  final String time;

  const TweetReplyModel({
    required this.id,
    required this.authorName,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.time,
  });
}

class TweetModel {
  final String id;
  final String authorName;
  final String username;
  final String avatarUrl;
  final String text;
  final String time;
  final TweetMediaType mediaType;

  /// ممكن يكون رابط network أو مسار local file
  final String? mediaUrl;

  final bool isLocalMedia;

  final int commentsCount;
  final int repostsCount;
  final int likesCount;
  final int viewsCount;
  final bool isLiked;
  final bool isReposted;
  final bool isMine;
  final List<TweetReplyModel> replies;

  const TweetModel({
    required this.id,
    required this.authorName,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.time,
    this.mediaType = TweetMediaType.none,
    this.mediaUrl,
    this.isLocalMedia = false,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isMine = false,
    this.replies = const [],
  });

  TweetModel copyWith({
    String? id,
    String? authorName,
    String? username,
    String? avatarUrl,
    String? text,
    String? time,
    TweetMediaType? mediaType,
    String? mediaUrl,
    bool? isLocalMedia,
    int? commentsCount,
    int? repostsCount,
    int? likesCount,
    int? viewsCount,
    bool? isLiked,
    bool? isReposted,
    bool? isMine,
    List<TweetReplyModel>? replies,
  }) {
    return TweetModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      text: text ?? this.text,
      time: time ?? this.time,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isLocalMedia: isLocalMedia ?? this.isLocalMedia,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      isMine: isMine ?? this.isMine,
      replies: replies ?? this.replies,
    );
  }
}
