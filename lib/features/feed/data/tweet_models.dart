class TweetUserModel {
  final String userId;
  final String username;
  final String photoUrl;
  final String accountColor;

  final String badgeKey;
  final String badgeName;
  final String badgeValue;
  final String verificationType;

  final List<Map<String, dynamic>> badges;

  const TweetUserModel({
    required this.userId,
    required this.username,
    required this.photoUrl,
    required this.accountColor,
    required this.badgeKey,
    required this.badgeName,
    required this.badgeValue,
    required this.verificationType,
    required this.badges,
  });

  factory TweetUserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawBadges = map['badges'];

    return TweetUserModel(
      userId: _stringValue(
        map['userId'] ?? map['user_id'],
      ),
      username: _stringValue(
        map['username'],
      ),
      photoUrl: _stringValue(
        map['photoUrl'] ?? map['photo_url'],
      ),
      accountColor: _stringValue(
        map['accountColor'] ??
            map['account_color'],
        fallback: '#2BCB00',
      ),
      badgeKey: _stringValue(
        map['badgeKey'] ?? map['badge_key'],
      ),
      badgeName: _stringValue(
        map['badgeName'] ?? map['badge_name'],
      ),
      badgeValue: _stringValue(
        map['badgeValue'] ??
            map['badge_value'],
      ),
      verificationType: _stringValue(
        map['verificationType'] ??
            map['verification_type'],
        fallback: 'none',
      ),
      badges: rawBadges is List
          ? rawBadges
              .whereType<Map>()
              .map(
                (item) =>
                    Map<String, dynamic>.from(item),
              )
              .toList()
          : const [],
    );
  }
}

class TweetMediaModel {
  final String type;
  final String url;
  final String publicId;
  final String thumbnailUrl;

  final int? width;
  final int? height;
  final double? duration;

  const TweetMediaModel({
    required this.type,
    required this.url,
    required this.publicId,
    required this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
  });

  bool get isImage =>
      type == 'image';

  bool get isVideo =>
      type == 'video';

  factory TweetMediaModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TweetMediaModel(
      type: _stringValue(
        map['type'],
        fallback: 'image',
      ),
      url: _stringValue(
        map['url'],
      ),
      publicId: _stringValue(
        map['publicId'] ??
            map['public_id'],
      ),
      thumbnailUrl: _stringValue(
        map['thumbnailUrl'] ??
            map['thumbnail_url'],
      ),
      width: _intValue(
        map['width'],
      ),
      height: _intValue(
        map['height'],
      ),
      duration: _doubleValue(
        map['duration'],
      ),
    );
  }
}

/*
  يستخدم عند إرسال صورة أو فيديو جديد
  إلى السيرفر أثناء إنشاء التويتة.

  Flutter يرسل Base64 إلى الباك.
  الباك يرفع الملف إلى Cloudinary.
  ثم يحفظ رابط secure_url داخل TweetModel.
*/
class TweetMediaInput {
  final String type;
  final String base64;
  final String fileName;
  final String mimeType;

  const TweetMediaInput({
    required this.type,
    required this.base64,
    required this.fileName,
    required this.mimeType,
  });

  factory TweetMediaInput.image({
    required String base64,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) {
    return TweetMediaInput(
      type: 'image',
      base64: base64,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  factory TweetMediaInput.video({
    required String base64,
    required String fileName,
    String mimeType = 'video/mp4',
  }) {
    return TweetMediaInput(
      type: 'video',
      base64: base64,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  bool get isImage =>
      type == 'image';

  bool get isVideo =>
      type == 'video';

  bool get isValid {
    return (isImage || isVideo) &&
        base64.trim().isNotEmpty &&
        fileName.trim().isNotEmpty &&
        mimeType.trim().isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'base64': base64,
      'file_name': fileName,
      'mime_type': mimeType,
    };
  }
}

class TweetRetweetUserModel {
  final String userId;
  final String username;
  final DateTime? createdAt;

  const TweetRetweetUserModel({
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory TweetRetweetUserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TweetRetweetUserModel(
      userId: _stringValue(
        map['userId'] ?? map['user_id'],
      ),
      username: _stringValue(
        map['username'],
      ),
      createdAt: _dateValue(
        map['createdAt'] ??
            map['created_at'],
      ),
    );
  }
}

class TweetModel {
  final String tweetId;
  final String text;
  final String mediaType;

  final List<TweetMediaModel> media;
  final List<String> mentions;

  final TweetUserModel? author;

  final int likesCount;
  final int commentsCount;
  final int retweetsCount;
  final int viewsCount;

  final bool isLiked;
  final bool isRetweeted;
  final bool canDelete;

  final TweetRetweetUserModel? retweetBy;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TweetModel({
    required this.tweetId,
    required this.text,
    required this.mediaType,
    required this.media,
    required this.mentions,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.retweetsCount,
    required this.viewsCount,
    required this.isLiked,
    required this.isRetweeted,
    required this.canDelete,
    required this.retweetBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TweetModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawMedia =
        map['media'];

    final rawMentions =
        map['mentions'];

    final rawAuthor =
        map['author'];

    final rawRetweetBy =
        map['retweetBy'] ??
        map['retweet_by'];

    return TweetModel(
      tweetId: _stringValue(
        map['tweetId'] ??
            map['tweet_id'],
      ),
      text: _stringValue(
        map['text'],
      ),
      mediaType: _stringValue(
        map['mediaType'] ??
            map['media_type'],
        fallback: 'none',
      ),
      media: rawMedia is List
          ? rawMedia
              .whereType<Map>()
              .map(
                (item) =>
                    TweetMediaModel.fromMap(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .toList()
          : const [],
      mentions: rawMentions is List
          ? rawMentions
              .map(
                (item) =>
                    item.toString(),
              )
              .toList()
          : const [],
      author: rawAuthor is Map
          ? TweetUserModel.fromMap(
              Map<String, dynamic>.from(
                rawAuthor,
              ),
            )
          : null,
      likesCount:
          _intValue(
            map['likesCount'] ??
                map['likes_count'],
          ) ??
          0,
      commentsCount:
          _intValue(
            map['commentsCount'] ??
                map['comments_count'],
          ) ??
          0,
      retweetsCount:
          _intValue(
            map['retweetsCount'] ??
                map['retweets_count'],
          ) ??
          0,
      viewsCount:
          _intValue(
            map['viewsCount'] ??
                map['views_count'],
          ) ??
          0,
      isLiked:
          map['isLiked'] == true ||
          map['is_liked'] == true,
      isRetweeted:
          map['isRetweeted'] == true ||
          map['is_retweeted'] == true,
      canDelete:
          map['canDelete'] == true ||
          map['can_delete'] == true,
      retweetBy: rawRetweetBy is Map
          ? TweetRetweetUserModel.fromMap(
              Map<String, dynamic>.from(
                rawRetweetBy,
              ),
            )
          : null,
      createdAt: _dateValue(
        map['createdAt'] ??
            map['created_at'],
      ),
      updatedAt: _dateValue(
        map['updatedAt'] ??
            map['updated_at'],
      ),
    );
  }

  TweetModel copyWith({
    String? text,
    int? likesCount,
    int? commentsCount,
    int? retweetsCount,
    int? viewsCount,
    bool? isLiked,
    bool? isRetweeted,
    bool? canDelete,
  }) {
    return TweetModel(
      tweetId: tweetId,
      text: text ?? this.text,
      mediaType: mediaType,
      media: media,
      mentions: mentions,
      author: author,
      likesCount:
          likesCount ??
          this.likesCount,
      commentsCount:
          commentsCount ??
          this.commentsCount,
      retweetsCount:
          retweetsCount ??
          this.retweetsCount,
      viewsCount:
          viewsCount ??
          this.viewsCount,
      isLiked:
          isLiked ??
          this.isLiked,
      isRetweeted:
          isRetweeted ??
          this.isRetweeted,
      canDelete:
          canDelete ??
          this.canDelete,
      retweetBy: retweetBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TweetCommentModel {
  final String commentId;
  final String tweetId;
  final String text;

  final TweetUserModel? author;
  final List<String> mentions;

  final bool isEdited;

  final DateTime? editedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TweetCommentModel({
    required this.commentId,
    required this.tweetId,
    required this.text,
    required this.author,
    required this.mentions,
    required this.isEdited,
    required this.editedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TweetCommentModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawAuthor =
        map['author'];

    final rawMentions =
        map['mentions'];

    return TweetCommentModel(
      commentId: _stringValue(
        map['commentId'] ??
            map['comment_id'],
      ),
      tweetId: _stringValue(
        map['tweetId'] ??
            map['tweet_id'],
      ),
      text: _stringValue(
        map['text'],
      ),
      author: rawAuthor is Map
          ? TweetUserModel.fromMap(
              Map<String, dynamic>.from(
                rawAuthor,
              ),
            )
          : null,
      mentions: rawMentions is List
          ? rawMentions
              .map(
                (item) =>
                    item.toString(),
              )
              .toList()
          : const [],
      isEdited:
          map['isEdited'] == true ||
          map['is_edited'] == true,
      editedAt: _dateValue(
        map['editedAt'] ??
            map['edited_at'],
      ),
      createdAt: _dateValue(
        map['createdAt'] ??
            map['created_at'],
      ),
      updatedAt: _dateValue(
        map['updatedAt'] ??
            map['updated_at'],
      ),
    );
  }
}

String _stringValue(
  dynamic value, {
  String fallback = '',
}) {
  if (value == null) {
    return fallback;
  }

  final result =
      value.toString().trim();

  if (result.isEmpty ||
      result == 'null' ||
      result == 'undefined') {
    return fallback;
  }

  return result;
}

int? _intValue(
  dynamic value,
) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value?.toString() ?? '',
  );
}

double? _doubleValue(
  dynamic value,
) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value?.toString() ?? '',
  );
}

DateTime? _dateValue(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(
    value.toString(),
  );
}