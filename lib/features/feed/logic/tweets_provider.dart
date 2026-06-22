import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/ws_event_bus.dart';
import '../data/tweet_models.dart';
import '../data/tweets_repository.dart';
import 'tweets_state.dart';

final tweetsProvider =
    StateNotifierProvider<TweetsController, TweetsState>(
  (ref) {
    return TweetsController(
      repository: const TweetsRepository(),
    );
  },
);

class TweetsController extends StateNotifier<TweetsState> {
  final TweetsRepository repository;

  StreamSubscription? _subscription;

  String? _lastRequestedCommentsTweetId;

  TweetsController({
    required this.repository,
  }) : super(const TweetsState()) {
    _attachSocketListener();
  }

  void _attachSocketListener() {
    _subscription?.cancel();

    _subscription = WsEventBus.instance.stream.listen(
      (event) {
        if (event is! Map) {
          return;
        }

        _handleSocketEvent(
          Map<String, dynamic>.from(event),
        );
      },
    );
  }

  void _handleSocketEvent(
    Map<String, dynamic> data,
  ) {
    final handler =
        data['handler']?.toString().trim() ?? '';

    final type =
        data['type']?.toString().trim() ?? '';

    final reason =
        data['reason']?.toString().trim() ??
        data['message']?.toString().trim() ??
        '';

    /*
      تجاهل أي حدث لا يخص التويتات.
    */
    if (!handler.startsWith('tweets.')) {
      return;
    }

    if (type == 'error') {
      _handleError(
        handler: handler,
        reason: reason,
        data: data,
      );

      return;
    }

    switch (handler) {
      case 'tweets.create_event':
        _handleTweetCreated(data);
        return;

      case 'tweets.delete_event':
        _handleTweetDeleted(data);
        return;

      case 'tweets.feed_event':
        _handleFeedLoaded(data);
        return;

      case 'tweets.details_event':
        _handleTweetDetails(data);
        return;

      case 'tweets.like_event':
        _handleLikeChanged(data);
        return;

      case 'tweets.retweet_event':
        _handleRetweetChanged(data);
        return;

      case 'tweets.view_event':
        _handleViewChanged(data);
        return;

      case 'tweets.comments_event':
        _handleCommentsLoaded(data);
        return;

      case 'tweets.comment_event':
        _handleCommentEvent(data);
        return;

      case 'tweets.cooldown_event':
        _handleCooldown(data);
        return;
    }
  }

  void loadFeed({
    String feedType = 'latest',
    bool refresh = true,
  }) {
    if (refresh) {
      state = state.copyWith(
        feedLoading: true,
        feedLoadingMore: false,
        feedType: feedType,
        clearFeedCursor: true,
        clearError: true,
      );

      try {
        repository.loadFeed(
          feedType: feedType,
          cursor: null,
        );
      } catch (error) {
        state = state.copyWith(
          feedLoading: false,
          feedLoadingMore: false,
          error: _cleanExceptionText(error),
        );
      }

      return;
    }

    if (state.feedLoadingMore) {
      return;
    }

    final cursor = state.feedCursor;

    if (cursor == null ||
        cursor.trim().isEmpty) {
      return;
    }

    state = state.copyWith(
      feedLoadingMore: true,
      clearError: true,
    );

    try {
      repository.loadFeed(
        feedType: state.feedType,
        cursor: cursor,
      );
    } catch (error) {
      state = state.copyWith(
        feedLoadingMore: false,
        error: _cleanExceptionText(error),
      );
    }
  }

  void createTweet({
    required String text,
    List<TweetMediaInput> media = const [],
  }) {
    /*
      منع تكرار الضغط أثناء رفع الوسائط إلى Cloudinary.
    */
    if (state.creatingTweet) {
      return;
    }

    final cleanText = text.trim();

    final invalidMedia = media
        .where(
          (item) => !item.isValid,
        )
        .toList(growable: false);

    if (invalidMedia.isNotEmpty) {
      state = state.copyWith(
        creatingTweet: false,
        error:
            'بيانات الصورة أو الفيديو غير مكتملة',
      );

      return;
    }

    final images = media
        .where(
          (item) => item.isImage,
        )
        .toList(growable: false);

    final videos = media
        .where(
          (item) => item.isVideo,
        )
        .toList(growable: false);

    if (cleanText.isEmpty &&
        media.isEmpty) {
      state = state.copyWith(
        error:
            'اكتب نصًا أو اختر صورة أو فيديو',
      );

      return;
    }

    if (images.length > 4) {
      state = state.copyWith(
        error:
            'يمكن اختيار أربع صور فقط',
      );

      return;
    }

    if (videos.length > 1) {
      state = state.copyWith(
        error:
            'يمكن اختيار فيديو واحد فقط',
      );

      return;
    }

    if (images.isNotEmpty &&
        videos.isNotEmpty) {
      state = state.copyWith(
        error:
            'لا يمكن جمع الصور والفيديو في تويتة واحدة',
      );

      return;
    }

    state = state.copyWith(
      creatingTweet: true,
      clearError: true,
      clearCooldown: true,
    );

    try {
      repository.createTweet(
        text: cleanText,
        media: media,
      );
    } catch (error) {
      state = state.copyWith(
        creatingTweet: false,
        error: _cleanExceptionText(error),
      );
    }
  }

  void deleteTweet({
    required String tweetId,
  }) {
    final id = tweetId.trim();

    if (id.isEmpty) {
      return;
    }

    if (state.pendingTweetIds.contains(id)) {
      return;
    }

    _addPendingTweet(id);

    try {
      repository.deleteTweet(
        tweetId: id,
      );
    } catch (error) {
      state = state.copyWith(
        pendingTweetIds: _withoutTweet(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void toggleLike({
    required String tweetId,
  }) {
    final id = tweetId.trim();

    if (id.isEmpty) {
      return;
    }

    if (state.pendingTweetIds.contains(id)) {
      return;
    }

    _addPendingTweet(id);

    try {
      repository.toggleLike(
        tweetId: id,
      );
    } catch (error) {
      state = state.copyWith(
        pendingTweetIds: _withoutTweet(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void toggleRetweet({
    required String tweetId,
  }) {
    final id = tweetId.trim();

    if (id.isEmpty) {
      return;
    }

    if (state.pendingTweetIds.contains(id)) {
      return;
    }

    _addPendingTweet(id);

    try {
      repository.toggleRetweet(
        tweetId: id,
      );
    } catch (error) {
      state = state.copyWith(
        pendingTweetIds: _withoutTweet(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void registerView({
    required String tweetId,
  }) {
    final id = tweetId.trim();

    if (id.isEmpty) {
      return;
    }

    try {
      repository.addView(
        tweetId: id,
      );
    } catch (_) {
      /*
        فشل تسجيل المشاهدة لا يمنع فتح التويتة.
      */
    }
  }

  void loadTweetDetails({
    required String tweetId,
  }) {
    final id = tweetId.trim();

    if (id.isEmpty) {
      return;
    }

    if (state.pendingTweetIds.contains(id)) {
      return;
    }

    _addPendingTweet(id);

    try {
      repository.getTweetDetails(
        tweetId: id,
      );
    } catch (error) {
      state = state.copyWith(
        pendingTweetIds: _withoutTweet(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void loadComments({
    required String tweetId,
    bool refresh = true,
  }) {
    final id = tweetId.trim();

    if (id.isEmpty) {
      return;
    }

    _lastRequestedCommentsTweetId = id;

    if (refresh) {
      final cursors =
          Map<String, String?>.from(
        state.commentsCursorByTweet,
      );

      cursors[id] = null;

      state = state.copyWith(
        commentsCursorByTweet: cursors,
        clearError: true,
      );

      try {
        repository.loadComments(
          tweetId: id,
          cursor: null,
        );
      } catch (error) {
        state = state.copyWith(
          error: _cleanExceptionText(error),
        );
      }

      return;
    }

    final cursor =
        state.commentsCursorByTweet[id];

    if (cursor == null ||
        cursor.trim().isEmpty) {
      return;
    }

    try {
      repository.loadComments(
        tweetId: id,
        cursor: cursor,
      );
    } catch (error) {
      state = state.copyWith(
        error: _cleanExceptionText(error),
      );
    }
  }

  void createComment({
    required String tweetId,
    required String text,
  }) {
    final id = tweetId.trim();
    final cleanText = text.trim();

    if (id.isEmpty) {
      return;
    }

    if (cleanText.isEmpty) {
      state = state.copyWith(
        error:
            'اكتب التعليق أولًا',
      );

      return;
    }

    if (state.pendingTweetIds.contains(id)) {
      return;
    }

    _addPendingTweet(id);

    try {
      repository.createComment(
        tweetId: id,
        text: cleanText,
      );
    } catch (error) {
      state = state.copyWith(
        pendingTweetIds: _withoutTweet(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void updateComment({
    required String commentId,
    required String text,
  }) {
    final id = commentId.trim();
    final cleanText = text.trim();

    if (id.isEmpty) {
      return;
    }

    if (cleanText.isEmpty) {
      state = state.copyWith(
        error:
            'التعليق لا يمكن أن يكون فارغًا',
      );

      return;
    }

    if (state.pendingCommentIds.contains(id)) {
      return;
    }

    _addPendingComment(id);

    try {
      repository.updateComment(
        commentId: id,
        text: cleanText,
      );
    } catch (error) {
      state = state.copyWith(
        pendingCommentIds:
            _withoutComment(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void deleteComment({
    required String commentId,
  }) {
    final id = commentId.trim();

    if (id.isEmpty) {
      return;
    }

    if (state.pendingCommentIds.contains(id)) {
      return;
    }

    _addPendingComment(id);

    try {
      repository.deleteComment(
        commentId: id,
      );
    } catch (error) {
      state = state.copyWith(
        pendingCommentIds:
            _withoutComment(id),
        error: _cleanExceptionText(error),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  void clearSelectedTweet() {
    state = state.copyWith(
      clearSelectedTweet: true,
    );
  }

  void clearAll() {
    _lastRequestedCommentsTweetId = null;

    state = const TweetsState();
  }

  void _handleTweetCreated(
    Map<String, dynamic> data,
  ) {
    final rawTweet = data['tweet'];

    if (rawTweet is! Map) {
      state = state.copyWith(
        creatingTweet: false,
        error:
            'تعذر قراءة التويتة الجديدة',
      );

      return;
    }

    final tweet = TweetModel.fromMap(
      Map<String, dynamic>.from(
        rawTweet,
      ),
    );

    if (tweet.tweetId.trim().isEmpty) {
      state = state.copyWith(
        creatingTweet: false,
        error:
            'معرّف التويتة الجديدة غير صالح',
      );

      return;
    }

    state = state.copyWith(
      tweets: [
        tweet,
        ...state.tweets.where(
          (item) =>
              item.tweetId != tweet.tweetId,
        ),
      ],
      selectedTweet: tweet,
      creatingTweet: false,
      clearError: true,
      clearCooldown: true,
    );
  }

  void _handleTweetDeleted(
    Map<String, dynamic> data,
  ) {
    final tweetId =
        (data['tweet_id'] ??
                data['tweetId'] ??
                '')
            .toString()
            .trim();

    if (tweetId.isEmpty) {
      state = state.copyWith(
        pendingTweetIds: const {},
        error:
            'تعذر تحديد التويتة المحذوفة',
      );

      return;
    }

    final comments =
        Map<String, List<TweetCommentModel>>.from(
      state.commentsByTweet,
    );

    comments.remove(tweetId);

    final cursors =
        Map<String, String?>.from(
      state.commentsCursorByTweet,
    );

    cursors.remove(tweetId);

    final shouldClearSelected =
        state.selectedTweet?.tweetId ==
            tweetId;

    state = state.copyWith(
      tweets: state.tweets
          .where(
            (tweet) =>
                tweet.tweetId != tweetId,
          )
          .toList(),
      commentsByTweet: comments,
      commentsCursorByTweet: cursors,
      pendingTweetIds:
          _withoutTweet(tweetId),
      clearSelectedTweet:
          shouldClearSelected,
      clearError: true,
    );
  }

  void _handleFeedLoaded(
    Map<String, dynamic> data,
  ) {
    final rawTweets = data['tweets'];

    final incoming = rawTweets is List
        ? rawTweets
            .whereType<Map>()
            .map(
              (item) => TweetModel.fromMap(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            )
            .where(
              (tweet) =>
                  tweet.tweetId.trim().isNotEmpty,
            )
            .toList()
        : <TweetModel>[];

    final isFirstPage =
        state.feedLoading;

    final merged = isFirstPage
        ? incoming
        : _mergeTweets(
            state.tweets,
            incoming,
          );

    final rawCursor =
        data['next_cursor'] ??
        data['nextCursor'];

    final nextCursor =
        rawCursor == null ||
                rawCursor.toString() == 'null' ||
                rawCursor.toString().trim().isEmpty
            ? null
            : rawCursor.toString().trim();

    state = state.copyWith(
      tweets: merged,
      feedLoading: false,
      feedLoadingMore: false,
      feedCursor: nextCursor,
      clearFeedCursor:
          nextCursor == null,
      clearError: true,
    );
  }

  void _handleTweetDetails(
    Map<String, dynamic> data,
  ) {
    final rawTweet = data['tweet'];

    if (rawTweet is! Map) {
      state = state.copyWith(
        pendingTweetIds: const {},
        error:
            'تعذر قراءة بيانات التويتة',
      );

      return;
    }

    final tweet = TweetModel.fromMap(
      Map<String, dynamic>.from(
        rawTweet,
      ),
    );

    state = state.copyWith(
      selectedTweet: tweet,
      tweets: _replaceTweet(
        state.tweets,
        tweet,
      ),
      pendingTweetIds:
          _withoutTweet(tweet.tweetId),
      clearError: true,
    );
  }

  void _handleLikeChanged(
    Map<String, dynamic> data,
  ) {
    final tweetId =
        (data['tweet_id'] ??
                data['tweetId'] ??
                '')
            .toString()
            .trim();

    if (tweetId.isEmpty) {
      state = state.copyWith(
        pendingTweetIds: const {},
      );

      return;
    }

    final liked =
        data['liked'] == true;

    final likesCount =
        _toInt(
          data['likes_count'] ??
              data['likesCount'],
        ) ??
        0;

    final updatedTweets =
        state.tweets.map((tweet) {
      if (tweet.tweetId != tweetId) {
        return tweet;
      }

      return tweet.copyWith(
        isLiked: liked,
        likesCount: likesCount,
      );
    }).toList();

    state = state.copyWith(
      tweets: updatedTweets,
      selectedTweet:
          _updateSelectedTweet(
        tweetId,
        (tweet) => tweet.copyWith(
          isLiked: liked,
          likesCount: likesCount,
        ),
      ),
      pendingTweetIds:
          _withoutTweet(tweetId),
      clearError: true,
    );
  }

  void _handleRetweetChanged(
    Map<String, dynamic> data,
  ) {
    final tweetId =
        (data['tweet_id'] ??
                data['tweetId'] ??
                '')
            .toString()
            .trim();

    if (tweetId.isEmpty) {
      state = state.copyWith(
        pendingTweetIds: const {},
      );

      return;
    }

    final retweeted =
        data['retweeted'] == true;

    final retweetsCount =
        _toInt(
          data['retweets_count'] ??
              data['retweetsCount'],
        ) ??
        0;

    state = state.copyWith(
      tweets: state.tweets.map((tweet) {
        if (tweet.tweetId != tweetId) {
          return tweet;
        }

        return tweet.copyWith(
          isRetweeted: retweeted,
          retweetsCount: retweetsCount,
        );
      }).toList(),
      selectedTweet:
          _updateSelectedTweet(
        tweetId,
        (tweet) => tweet.copyWith(
          isRetweeted: retweeted,
          retweetsCount: retweetsCount,
        ),
      ),
      pendingTweetIds:
          _withoutTweet(tweetId),
      clearError: true,
    );
  }

  void _handleViewChanged(
    Map<String, dynamic> data,
  ) {
    final tweetId =
        (data['tweet_id'] ??
                data['tweetId'] ??
                '')
            .toString()
            .trim();

    if (tweetId.isEmpty) {
      return;
    }

    final viewsCount =
        _toInt(
          data['views_count'] ??
              data['viewsCount'],
        ) ??
        0;

    state = state.copyWith(
      tweets: state.tweets.map((tweet) {
        if (tweet.tweetId != tweetId) {
          return tweet;
        }

        return tweet.copyWith(
          viewsCount: viewsCount,
        );
      }).toList(),
      selectedTweet:
          _updateSelectedTweet(
        tweetId,
        (tweet) => tweet.copyWith(
          viewsCount: viewsCount,
        ),
      ),
    );
  }

  void _handleCommentsLoaded(
    Map<String, dynamic> data,
  ) {
    final rawComments =
        data['comments'];

    final comments = rawComments is List
        ? rawComments
            .whereType<Map>()
            .map(
              (item) =>
                  TweetCommentModel.fromMap(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            )
            .toList()
        : <TweetCommentModel>[];

    String tweetId =
        (data['tweet_id'] ??
                data['tweetId'] ??
                '')
            .toString()
            .trim();

    if (tweetId.isEmpty &&
        comments.isNotEmpty) {
      tweetId =
          comments.first.tweetId;
    }

    if (tweetId.isEmpty) {
      tweetId =
          _lastRequestedCommentsTweetId ??
              '';
    }

    if (tweetId.isEmpty) {
      return;
    }

    final updatedComments =
        Map<String, List<TweetCommentModel>>.from(
      state.commentsByTweet,
    );

    final oldComments =
        updatedComments[tweetId] ??
            const <TweetCommentModel>[];

    final isFirstPage =
        state.commentsCursorByTweet[tweetId] ==
            null;

    updatedComments[tweetId] =
        isFirstPage
            ? comments
            : _mergeComments(
                oldComments,
                comments,
              );

    final cursors =
        Map<String, String?>.from(
      state.commentsCursorByTweet,
    );

    final rawCursor =
        data['next_cursor'] ??
        data['nextCursor'];

    cursors[tweetId] =
        rawCursor == null ||
                rawCursor.toString() == 'null' ||
                rawCursor.toString().trim().isEmpty
            ? null
            : rawCursor.toString().trim();

    state = state.copyWith(
      commentsByTweet:
          updatedComments,
      commentsCursorByTweet:
          cursors,
      clearError: true,
    );
  }

  void _handleCommentEvent(
    Map<String, dynamic> data,
  ) {
    final eventType =
        data['type']?.toString().trim() ?? '';

    if (eventType == 'deleted') {
      final commentId =
          (data['comment_id'] ??
                  data['commentId'] ??
                  '')
              .toString()
              .trim();

      final tweetId =
          (data['tweet_id'] ??
                  data['tweetId'] ??
                  '')
              .toString()
              .trim();

      final comments =
          Map<String, List<TweetCommentModel>>.from(
        state.commentsByTweet,
      );

      if (tweetId.isNotEmpty) {
        comments[tweetId] =
            (comments[tweetId] ??
                    const <TweetCommentModel>[])
                .where(
                  (comment) =>
                      comment.commentId !=
                      commentId,
                )
                .toList();
      } else {
        for (final entry
            in comments.entries.toList()) {
          comments[entry.key] = entry.value
              .where(
                (comment) =>
                    comment.commentId !=
                    commentId,
              )
              .toList();
        }
      }

      state = state.copyWith(
        commentsByTweet: comments,
        tweets: tweetId.isEmpty
            ? state.tweets
            : _changeCommentsCount(
                tweetId,
                -1,
              ),
        selectedTweet: tweetId.isEmpty
            ? state.selectedTweet
            : _changeSelectedCommentsCount(
                tweetId,
                -1,
              ),
        pendingCommentIds:
            commentId.isEmpty
                ? const {}
                : _withoutComment(
                    commentId,
                  ),
        clearError: true,
      );

      return;
    }

    final rawComment =
        data['comment'];

    if (rawComment is! Map) {
      state = state.copyWith(
        pendingTweetIds: const {},
        pendingCommentIds: const {},
        error:
            'تعذر قراءة بيانات التعليق',
      );

      return;
    }

    final comment =
        TweetCommentModel.fromMap(
      Map<String, dynamic>.from(
        rawComment,
      ),
    );

    final comments =
        Map<String, List<TweetCommentModel>>.from(
      state.commentsByTweet,
    );

    final current =
        comments[comment.tweetId] ??
            const <TweetCommentModel>[];

    if (eventType == 'updated') {
      comments[comment.tweetId] =
          current.map((item) {
        if (item.commentId ==
            comment.commentId) {
          return comment;
        }

        return item;
      }).toList();
    } else {
      comments[comment.tweetId] = [
        comment,
        ...current.where(
          (item) =>
              item.commentId !=
              comment.commentId,
        ),
      ];
    }

    final isCreated =
        eventType == 'created';

    state = state.copyWith(
      commentsByTweet: comments,
      tweets: isCreated
          ? _changeCommentsCount(
              comment.tweetId,
              1,
            )
          : state.tweets,
      selectedTweet: isCreated
          ? _changeSelectedCommentsCount(
              comment.tweetId,
              1,
            )
          : state.selectedTweet,
      pendingTweetIds:
          _withoutTweet(
        comment.tweetId,
      ),
      pendingCommentIds:
          _withoutComment(
        comment.commentId,
      ),
      clearError: true,
    );
  }

  void _handleCooldown(
    Map<String, dynamic> data,
  ) {
    final seconds =
        _toInt(
          data['remaining_seconds'] ??
              data['remainingSeconds'],
        ) ??
        0;

    state = state.copyWith(
      creatingTweet: false,
      cooldownRemainingSeconds:
          seconds,
      error:
          'يمكنك نشر تويتة جديدة بعد $seconds ثانية',
    );
  }

  void _handleError({
    required String handler,
    required String reason,
    required Map<String, dynamic> data,
  }) {
    final tweetId =
        (data['tweet_id'] ??
                data['tweetId'] ??
                '')
            .toString()
            .trim();

    final commentId =
        (data['comment_id'] ??
                data['commentId'] ??
                '')
            .toString()
            .trim();

    Set<String> pendingTweets =
        state.pendingTweetIds;

    Set<String> pendingComments =
        state.pendingCommentIds;

    if (tweetId.isNotEmpty) {
      pendingTweets =
          _withoutTweet(tweetId);
    } else if (handler ==
            'tweets.like_event' ||
        handler ==
            'tweets.retweet_event' ||
        handler ==
            'tweets.details_event' ||
        handler ==
            'tweets.delete_event') {
      /*
        بعض أخطاء السيرفر لا تعيد tweet_id.
      */
      pendingTweets = <String>{};
    }

    if (commentId.isNotEmpty) {
      pendingComments =
          _withoutComment(commentId);
    } else if (handler ==
        'tweets.comment_event') {
      pendingComments = <String>{};
      pendingTweets = <String>{};
    }

    state = state.copyWith(
      feedLoading: false,
      feedLoadingMore: false,
      creatingTweet:
          handler == 'tweets.create_event'
              ? false
              : state.creatingTweet,
      pendingTweetIds: pendingTweets,
      pendingCommentIds: pendingComments,
      error: _errorText(reason),
    );
  }

  void _addPendingTweet(
    String tweetId,
  ) {
    state = state.copyWith(
      pendingTweetIds: {
        ...state.pendingTweetIds,
        tweetId,
      },
      clearError: true,
    );
  }

  void _addPendingComment(
    String commentId,
  ) {
    state = state.copyWith(
      pendingCommentIds: {
        ...state.pendingCommentIds,
        commentId,
      },
      clearError: true,
    );
  }

  Set<String> _withoutTweet(
    String tweetId,
  ) {
    return {
      ...state.pendingTweetIds.where(
        (item) => item != tweetId,
      ),
    };
  }

  Set<String> _withoutComment(
    String commentId,
  ) {
    return {
      ...state.pendingCommentIds.where(
        (item) => item != commentId,
      ),
    };
  }

  List<TweetModel> _replaceTweet(
    List<TweetModel> tweets,
    TweetModel updated,
  ) {
    final exists = tweets.any(
      (tweet) =>
          tweet.tweetId ==
          updated.tweetId,
    );

    if (!exists) {
      return [
        updated,
        ...tweets,
      ];
    }

    return tweets.map((tweet) {
      if (tweet.tweetId ==
          updated.tweetId) {
        return updated;
      }

      return tweet;
    }).toList();
  }

  List<TweetModel> _mergeTweets(
    List<TweetModel> oldTweets,
    List<TweetModel> newTweets,
  ) {
    final map =
        <String, TweetModel>{};

    for (final tweet in oldTweets) {
      map[tweet.tweetId] = tweet;
    }

    for (final tweet in newTweets) {
      map[tweet.tweetId] = tweet;
    }

    return map.values.toList();
  }

  List<TweetCommentModel> _mergeComments(
    List<TweetCommentModel> oldComments,
    List<TweetCommentModel> newComments,
  ) {
    final map =
        <String, TweetCommentModel>{};

    for (final comment in oldComments) {
      map[comment.commentId] =
          comment;
    }

    for (final comment in newComments) {
      map[comment.commentId] =
          comment;
    }

    return map.values.toList();
  }

  List<TweetModel> _changeCommentsCount(
    String tweetId,
    int difference,
  ) {
    return state.tweets.map((tweet) {
      if (tweet.tweetId != tweetId) {
        return tweet;
      }

      final newCount =
          tweet.commentsCount +
          difference;

      return tweet.copyWith(
        commentsCount:
            newCount < 0
                ? 0
                : newCount,
      );
    }).toList();
  }

  TweetModel? _changeSelectedCommentsCount(
    String tweetId,
    int difference,
  ) {
    final selected =
        state.selectedTweet;

    if (selected == null ||
        selected.tweetId != tweetId) {
      return selected;
    }

    final newCount =
        selected.commentsCount +
        difference;

    return selected.copyWith(
      commentsCount:
          newCount < 0
              ? 0
              : newCount,
    );
  }

  TweetModel? _updateSelectedTweet(
    String tweetId,
    TweetModel Function(
      TweetModel tweet,
    )
        update,
  ) {
    final selectedTweet =
        state.selectedTweet;

    if (selectedTweet == null ||
        selectedTweet.tweetId !=
            tweetId) {
      return selectedTweet;
    }

    return update(selectedTweet);
  }

  String _errorText(
    String reason,
  ) {
    switch (reason) {
      case 'tweet_cooldown':
        return 'يجب الانتظار خمس دقائق قبل نشر تويتة أخرى';

      case 'tweet_content_required':
        return 'اكتب نصًا أو اختر صورة أو فيديو';

      case 'tweet_text_too_long':
        return 'نص التويتة طويل جدًا';

      case 'too_many_tweet_images':
      case 'tweet_images_limit_exceeded':
        return 'يمكن اختيار أربع صور فقط';

      case 'only_one_video_allowed':
      case 'tweet_video_limit_exceeded':
        return 'يمكن اختيار فيديو واحد فقط';

      case 'cannot_mix_images_and_video':
      case 'tweet_media_cannot_mix_images_and_video':
        return 'لا يمكن جمع الصور والفيديو في تويتة واحدة';

      case 'invalid_media_type':
      case 'invalid_tweet_media_type':
        return 'نوع الوسائط غير صحيح';

      case 'invalid_tweet_media_item':
        return 'بيانات الصورة أو الفيديو غير صحيحة';

      case 'tweet_media_source_required':
      case 'tweet_media_base64_required':
        return 'تعذر قراءة الصورة أو الفيديو';

      case 'tweet_media_mime_type_required':
        return 'نوع ملف الوسائط غير معروف';

      case 'invalid_tweet_media_base64':
        return 'ملف الصورة أو الفيديو تالف';

      case 'empty_tweet_media_file':
        return 'ملف الصورة أو الفيديو فارغ';

      case 'unsupported_tweet_image_type':
        return 'صيغة الصورة غير مدعومة';

      case 'unsupported_tweet_video_type':
        return 'صيغة الفيديو غير مدعومة';

      case 'tweet_image_too_large':
        return 'حجم الصورة أكبر من الحد المسموح';

      case 'tweet_video_too_large':
        return 'حجم الفيديو أكبر من الحد المسموح';

      case 'tweet_media_upload_failed':
      case 'cloudinary_upload_failed':
      case 'cloudinary_empty_upload_result':
      case 'invalid_cloudinary_upload_result':
        return 'فشل رفع الوسائط، حاول مرة أخرى';

      case 'invalid_create_tweet_payload':
        return 'بيانات التويتة المرسلة غير صحيحة';

      case 'tweet_not_found':
        return 'التويتة غير موجودة';

      case 'tweet_delete_forbidden':
        return 'لا يمكنك حذف تويتة مستخدم آخر';

      case 'comment_text_required':
        return 'اكتب التعليق أولًا';

      case 'comment_text_too_long':
        return 'التعليق طويل جدًا';

      case 'comment_not_found':
        return 'التعليق غير موجود';

      case 'comment_update_forbidden':
        return 'لا يمكنك تعديل تعليق مستخدم آخر';

      case 'comment_delete_forbidden':
        return 'لا يمكنك حذف تعليق مستخدم آخر';

      case 'unauthorized':
        return 'يجب تسجيل الدخول أولًا';

      default:
        return reason.trim().isEmpty
            ? 'حدث خطأ غير معروف'
            : reason;
    }
  }

  String _cleanExceptionText(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Invalid argument(s): ',
          '',
        )
        .replaceFirst(
          'Invalid argument: ',
          '',
        )
        .replaceFirst(
          'ArgumentError: ',
          '',
        )
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }
}

int? _toInt(
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