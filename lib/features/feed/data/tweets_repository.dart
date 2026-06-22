import 'package:uuid/uuid.dart';

import '../../../core/network/ws_background_controller.dart';
import 'tweet_models.dart';

class TweetsRepository {
  const TweetsRepository();

  static const Uuid _uuid = Uuid();

  String _newRequestId() {
    return _uuid.v4();
  }

  void createTweet({
    required String text,
    List<TweetMediaInput> media = const [],
  }) {
    final cleanText = text.trim();

    /*
      نقبل فقط العناصر المكتملة:
      النوع + Base64 + اسم الملف + MIME type.
    */
    final validMedia = media
        .where(
          (item) => item.isValid,
        )
        .toList(growable: false);

    final images = validMedia
        .where(
          (item) => item.isImage,
        )
        .toList(growable: false);

    final videos = validMedia
        .where(
          (item) => item.isVideo,
        )
        .toList(growable: false);

    if (images.length > 4) {
      throw ArgumentError(
        'يمكن اختيار أربع صور فقط',
      );
    }

    if (videos.length > 1) {
      throw ArgumentError(
        'يمكن اختيار فيديو واحد فقط',
      );
    }

    if (images.isNotEmpty &&
        videos.isNotEmpty) {
      throw ArgumentError(
        'لا يمكن جمع الصور والفيديو في تويتة واحدة',
      );
    }

    /*
      لو تم تمرير وسائط غير صالحة نوقف الإرسال،
      بدل تجاهلها وإنشاء تويتة ناقصة.
    */
    if (media.isNotEmpty &&
        validMedia.length != media.length) {
      throw ArgumentError(
        'بيانات الصورة أو الفيديو غير مكتملة',
      );
    }

    if (cleanText.isEmpty &&
        validMedia.isEmpty) {
      throw ArgumentError(
        'يجب كتابة نص أو اختيار صورة أو فيديو',
      );
    }

    final String mediaType;

    if (videos.isNotEmpty) {
      mediaType = 'video';
    } else if (images.isNotEmpty) {
      mediaType = 'images';
    } else {
      mediaType = 'none';
    }

    final requestId =
        _newRequestId();

    final payload = <String, dynamic>{
      'handler': 'tweets.create',
      'request_id': requestId,
      'text': cleanText,
      'media_type': mediaType,
      'media': validMedia
          .map(
            (item) => item.toMap(),
          )
          .toList(growable: false),
    };

    sendBackgroundWs(payload);
  }

  void deleteTweet({
    required String tweetId,
  }) {
    final cleanTweetId =
        tweetId.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.delete',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
    });
  }

  void loadFeed({
    String feedType = 'latest',
    String? cursor,
    int limit = 20,
  }) {
    final cleanFeedType =
        feedType.trim().isEmpty
            ? 'latest'
            : feedType.trim();

    final safeLimit =
        limit.clamp(1, 50);

    sendBackgroundWs({
      'handler': 'tweets.feed',
      'request_id': _newRequestId(),
      'feed_type': cleanFeedType,
      if (cursor != null &&
          cursor.trim().isNotEmpty)
        'cursor': cursor.trim(),
      'limit': safeLimit,
    });
  }

  void getTweetDetails({
    required String tweetId,
  }) {
    final cleanTweetId =
        tweetId.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.details',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
    });
  }

  void toggleLike({
    required String tweetId,
  }) {
    final cleanTweetId =
        tweetId.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.like.toggle',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
    });
  }

  void toggleRetweet({
    required String tweetId,
  }) {
    final cleanTweetId =
        tweetId.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.retweet.toggle',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
    });
  }

  void addView({
    required String tweetId,
  }) {
    final cleanTweetId =
        tweetId.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.view',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
    });
  }

  void loadComments({
    required String tweetId,
    String? cursor,
    int limit = 20,
  }) {
    final cleanTweetId =
        tweetId.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    final safeLimit =
        limit.clamp(1, 50);

    sendBackgroundWs({
      'handler': 'tweets.comments.list',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
      if (cursor != null &&
          cursor.trim().isNotEmpty)
        'cursor': cursor.trim(),
      'limit': safeLimit,
    });
  }

  void createComment({
    required String tweetId,
    required String text,
  }) {
    final cleanTweetId =
        tweetId.trim();

    final cleanComment =
        text.trim();

    if (cleanTweetId.isEmpty) {
      throw ArgumentError(
        'tweetId is required',
      );
    }

    if (cleanComment.isEmpty) {
      throw ArgumentError(
        'يجب كتابة التعليق',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.comment.create',
      'request_id': _newRequestId(),
      'tweet_id': cleanTweetId,
      'text': cleanComment,
    });
  }

  void updateComment({
    required String commentId,
    required String text,
  }) {
    final cleanCommentId =
        commentId.trim();

    final cleanComment =
        text.trim();

    if (cleanCommentId.isEmpty) {
      throw ArgumentError(
        'commentId is required',
      );
    }

    if (cleanComment.isEmpty) {
      throw ArgumentError(
        'يجب كتابة التعليق',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.comment.update',
      'request_id': _newRequestId(),
      'comment_id': cleanCommentId,
      'text': cleanComment,
    });
  }

  void deleteComment({
    required String commentId,
  }) {
    final cleanCommentId =
        commentId.trim();

    if (cleanCommentId.isEmpty) {
      throw ArgumentError(
        'commentId is required',
      );
    }

    sendBackgroundWs({
      'handler': 'tweets.comment.delete',
      'request_id': _newRequestId(),
      'comment_id': cleanCommentId,
    });
  }
}