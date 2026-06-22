import '../data/tweet_models.dart';

class TweetsState {
  final List<TweetModel> tweets;

  final TweetModel? selectedTweet;

  final Map<String, List<TweetCommentModel>>
  commentsByTweet;

  final Map<String, String?>
  commentsCursorByTweet;

  final bool feedLoading;
  final bool feedLoadingMore;
  final bool creatingTweet;

  final String feedType;
  final String? feedCursor;

  final Set<String> pendingTweetIds;
  final Set<String> pendingCommentIds;

  final int? cooldownRemainingSeconds;

  final String? error;

  const TweetsState({
    this.tweets = const [],
    this.selectedTweet,
    this.commentsByTweet = const {},
    this.commentsCursorByTweet = const {},
    this.feedLoading = false,
    this.feedLoadingMore = false,
    this.creatingTweet = false,
    this.feedType = 'latest',
    this.feedCursor,
    this.pendingTweetIds = const {},
    this.pendingCommentIds = const {},
    this.cooldownRemainingSeconds,
    this.error,
  });

  TweetsState copyWith({
    List<TweetModel>? tweets,
    TweetModel? selectedTweet,
    bool clearSelectedTweet = false,

    Map<String, List<TweetCommentModel>>?
    commentsByTweet,

    Map<String, String?>?
    commentsCursorByTweet,

    bool? feedLoading,
    bool? feedLoadingMore,
    bool? creatingTweet,

    String? feedType,
    String? feedCursor,
    bool clearFeedCursor = false,

    Set<String>? pendingTweetIds,
    Set<String>? pendingCommentIds,

    int? cooldownRemainingSeconds,
    bool clearCooldown = false,

    String? error,
    bool clearError = false,
  }) {
    return TweetsState(
      tweets: tweets ?? this.tweets,
      selectedTweet: clearSelectedTweet
          ? null
          : selectedTweet ?? this.selectedTweet,
      commentsByTweet:
          commentsByTweet ?? this.commentsByTweet,
      commentsCursorByTweet:
          commentsCursorByTweet ??
          this.commentsCursorByTweet,
      feedLoading:
          feedLoading ?? this.feedLoading,
      feedLoadingMore:
          feedLoadingMore ??
          this.feedLoadingMore,
      creatingTweet:
          creatingTweet ?? this.creatingTweet,
      feedType:
          feedType ?? this.feedType,
      feedCursor: clearFeedCursor
          ? null
          : feedCursor ?? this.feedCursor,
      pendingTweetIds:
          pendingTweetIds ??
          this.pendingTweetIds,
      pendingCommentIds:
          pendingCommentIds ??
          this.pendingCommentIds,
      cooldownRemainingSeconds:
          clearCooldown
          ? null
          : cooldownRemainingSeconds ??
                this.cooldownRemainingSeconds,
      error: clearError
          ? null
          : error ?? this.error,
    );
  }
}