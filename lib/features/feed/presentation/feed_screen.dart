import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/tweet_model.dart';
import 'tweet_create_screen.dart';
import 'tweet_details_screen.dart';
import 'widgets/tweet_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<TweetModel> tweets = [
    const TweetModel(
      id: '1',
      authorName: 'Mohammed',
      username: 'mohammed',
      avatarUrl: '',
      text: 'ده مثال لتويتة نص فقط داخل Bimo مع @Mostafa و #BimoChat.',
      time: '2m',
      commentsCount: 3,
      repostsCount: 1,
      likesCount: 18,
      viewsCount: 320,
      isMine: true,
    ),
    const TweetModel(
      id: '2',
      authorName: 'Bimo',
      username: 'bimo',
      avatarUrl: '',
      text: 'Tweet with image preview #Design',
      time: '15m',
      mediaType: TweetMediaType.image,
      mediaUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
      commentsCount: 7,
      repostsCount: 4,
      likesCount: 40,
      viewsCount: 900,
    ),
    const TweetModel(
      id: '3',
      authorName: 'Sara',
      username: 'sara',
      avatarUrl: '',
      text: 'Video tweet preview with @Mohammed',
      time: '1h',
      mediaType: TweetMediaType.video,
      mediaUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200',
      commentsCount: 2,
      repostsCount: 3,
      likesCount: 12,
      viewsCount: 450,
    ),
  ];

  void openCreateTweetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TweetCreateScreen(onPost: addTweet)),
    );
  }

  void addTweet(TweetCreateResult result) {
    setState(() {
      tweets.insert(
        0,
        TweetModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorName: 'Mohammed',
          username: 'mohammed',
          avatarUrl: '',
          text: result.text,
          time: 'now',
          mediaType: result.mediaType,
          mediaUrl: result.mediaPath,
          isLocalMedia: result.mediaPath != null,
          commentsCount: 0,
          repostsCount: 0,
          likesCount: 0,
          viewsCount: 0,
          isMine: true,
        ),
      );
    });
  }

  void openTweetDetails(TweetModel tweet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TweetDetailsScreen(tweet: tweet, onTweetChanged: updateTweet),
      ),
    );
  }

  void updateTweet(TweetModel updatedTweet) {
    final index = tweets.indexWhere((item) => item.id == updatedTweet.id);

    if (index == -1) return;

    setState(() {
      tweets[index] = updatedTweet;
    });
  }

  void deleteTweet(TweetModel tweet) {
    setState(() {
      tweets.removeWhere((item) => item.id == tweet.id);
    });
  }

  void toggleLike(TweetModel tweet) {
    final index = tweets.indexWhere((item) => item.id == tweet.id);
    if (index == -1) return;

    final current = tweets[index];

    setState(() {
      tweets[index] = current.copyWith(
        isLiked: !current.isLiked,
        likesCount: current.isLiked
            ? current.likesCount - 1
            : current.likesCount + 1,
      );
    });
  }

  void toggleRepost(TweetModel tweet) {
    final index = tweets.indexWhere((item) => item.id == tweet.id);
    if (index == -1) return;

    final current = tweets[index];

    setState(() {
      tweets[index] = current.copyWith(
        isReposted: !current.isReposted,
        repostsCount: current.isReposted
            ? current.repostsCount - 1
            : current.repostsCount + 1,
      );
    });
  }

  void addQuickReply(TweetModel tweet) {
    final index = tweets.indexWhere((item) => item.id == tweet.id);
    if (index == -1) return;

    final reply = TweetReplyModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Mohammed',
      username: 'mohammed',
      avatarUrl: '',
      text: 'Reply added',
      time: 'now',
    );

    setState(() {
      tweets[index] = tweets[index].copyWith(
        commentsCount: tweets[index].commentsCount + 1,
        replies: [reply, ...tweets[index].replies],
      );
    });

    openTweetDetails(tweets[index]);
  }

  void shareTweet(TweetModel tweet) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateTweetScreen,
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.surface,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: R.size(context, 58),
              padding: EdgeInsets.symmetric(horizontal: R.size(context, 16)),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    width: 0.7,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Feed',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: R.sp(context, 24),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  final tweet = tweets[index];

                  return TweetCard(
                    tweet: tweet,
                    onTap: () => openTweetDetails(tweet),
                    onCommentTap: () => openTweetDetails(tweet),
                    onRepostTap: () => toggleRepost(tweet),
                    onLikeTap: () => toggleLike(tweet),
                    onDeleteTap: () => deleteTweet(tweet),
                    onShareTap: () => shareTweet(tweet),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
