import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';

import '../data/tweet_models.dart';
import '../logic/tweets_provider.dart';

import 'tweet_create_screen.dart';
import 'tweet_details_screen.dart';
import 'widgets/tweet_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({
    super.key,
  });

  @override
  ConsumerState<FeedScreen> createState() =>
      _FeedScreenState();
}

class _FeedScreenState
    extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController =
      ScrollController();

  bool _feedRequested = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );

    Future.microtask(
      _loadInitialFeed,
    );
  }

  void _loadInitialFeed() {
    if (_feedRequested) {
      return;
    }

    _feedRequested = true;

    ref
        .read(tweetsProvider.notifier)
        .loadFeed(
          feedType: 'latest',
          refresh: true,
        );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 300) {
      ref
          .read(tweetsProvider.notifier)
          .loadFeed(
            refresh: false,
          );
    }
  }

  Future<void> _refreshFeed() async {
    ref
        .read(tweetsProvider.notifier)
        .loadFeed(
          feedType: 'latest',
          refresh: true,
        );

    await Future<void>.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );
  }

  void openCreateTweetScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return TweetCreateScreen(
            onPost: (
              result,
            ) async {
              final media =
                  <TweetMediaInput>[];

              /*
                تحويل الصور المختارة إلى Base64.
              */
              for (
                var index = 0;
                index <
                    result.imagePaths.length;
                index++
              ) {
                final path =
                    result.imagePaths[index]
                        .trim();

                if (path.isEmpty) {
                  throw Exception(
                    'مسار الصورة غير صالح',
                  );
                }

                final file =
                    File(path);

                final exists =
                    await file.exists();

                if (!exists) {
                  throw Exception(
                    'ملف الصورة غير موجود',
                  );
                }

                final bytes =
                    await file.readAsBytes();

                if (bytes.isEmpty) {
                  throw Exception(
                    'ملف الصورة فارغ',
                  );
                }

                const maxImageSize =
                    10 * 1024 * 1024;

                if (bytes.length >
                    maxImageSize) {
                  throw Exception(
                    'حجم الصورة يجب ألا يتجاوز 10MB',
                  );
                }

                final extension =
                    _fileExtension(
                  path,
                  defaultExtension: 'jpg',
                );

                final mimeType =
                    _imageMimeType(
                  extension,
                );

                final encoded =
                    base64Encode(bytes);

                final timestamp =
                    DateTime.now()
                        .millisecondsSinceEpoch;

                media.add(
                  TweetMediaInput.image(
                    base64:
                        'data:$mimeType;base64,$encoded',
                    fileName:
                        'tweet_image_${timestamp}_$index.$extension',
                    mimeType:
                        mimeType,
                  ),
                );
              }

              /*
                تحويل الفيديو المختار إلى Base64.
              */
              final videoPath =
                  result.videoPath?.trim();

              if (videoPath != null &&
                  videoPath.isNotEmpty) {
                final file =
                    File(videoPath);

                final exists =
                    await file.exists();

                if (!exists) {
                  throw Exception(
                    'ملف الفيديو غير موجود',
                  );
                }

                final bytes =
                    await file.readAsBytes();

                if (bytes.isEmpty) {
                  throw Exception(
                    'ملف الفيديو فارغ',
                  );
                }

                const maxVideoSize =
                    30 * 1024 * 1024;

                if (bytes.length >
                    maxVideoSize) {
                  throw Exception(
                    'حجم الفيديو يجب ألا يتجاوز 30MB',
                  );
                }

                final extension =
                    _fileExtension(
                  videoPath,
                  defaultExtension: 'mp4',
                );

                final mimeType =
                    _videoMimeType(
                  extension,
                );

                final encoded =
                    base64Encode(bytes);

                final timestamp =
                    DateTime.now()
                        .millisecondsSinceEpoch;

                media.add(
                  TweetMediaInput.video(
                    base64:
                        'data:$mimeType;base64,$encoded',
                    fileName:
                        'tweet_video_$timestamp.$extension',
                    mimeType:
                        mimeType,
                  ),
                );
              }

              ref
                  .read(
                    tweetsProvider.notifier,
                  )
                  .createTweet(
                    text:
                        result.text.trim(),
                    media:
                        media,
                  );
            },
          );
        },
      ),
    );
  }

  String _fileExtension(
    String filePath, {
    required String defaultExtension,
  }) {
    final cleanPath =
        filePath
            .split('?')
            .first
            .trim();

    final lastSlash =
        cleanPath.lastIndexOf('/');

    final lastBackslash =
        cleanPath.lastIndexOf('\\');

    final separatorIndex =
        lastSlash > lastBackslash
            ? lastSlash
            : lastBackslash;

    final fileName =
        separatorIndex >= 0
            ? cleanPath.substring(
                separatorIndex + 1,
              )
            : cleanPath;

    final dotIndex =
        fileName.lastIndexOf('.');

    if (dotIndex < 0 ||
        dotIndex ==
            fileName.length - 1) {
      return defaultExtension;
    }

    final extension =
        fileName
            .substring(
              dotIndex + 1,
            )
            .toLowerCase()
            .trim();

    if (extension.isEmpty) {
      return defaultExtension;
    }

    return extension;
  }

  String _imageMimeType(
    String extension,
  ) {
    switch (
        extension.toLowerCase()) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'gif':
        return 'image/gif';

      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  String _videoMimeType(
    String extension,
  ) {
    switch (
        extension.toLowerCase()) {
      case 'webm':
        return 'video/webm';

      case 'mov':
        return 'video/quicktime';

      case 'mkv':
        return 'video/x-matroska';

      case 'mp4':
      default:
        return 'video/mp4';
    }
  }

  void openTweetDetails(
    TweetModel tweet,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return TweetDetailsScreen(
            tweet: tweet,
          );
        },
      ),
    );
  }

  void deleteTweet(
    TweetModel tweet,
  ) {
    if (!tweet.canDelete) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete Tweet',
          ),
          content: const Text(
            'Are you sure you want to delete this tweet?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();

                ref
                    .read(
                      tweetsProvider.notifier,
                    )
                    .deleteTweet(
                      tweetId:
                          tweet.tweetId,
                    );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void toggleLike(
    TweetModel tweet,
  ) {
    ref
        .read(tweetsProvider.notifier)
        .toggleLike(
          tweetId:
              tweet.tweetId,
        );
  }

  void toggleRetweet(
    TweetModel tweet,
  ) {
    ref
        .read(tweetsProvider.notifier)
        .toggleRetweet(
          tweetId:
              tweet.tweetId,
        );
  }

  void addQuickReply(
    TweetModel tweet,
  ) {
    openTweetDetails(
      tweet,
    );
  }

  void shareTweet(
    TweetModel tweet,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Tweet ID: ${tweet.tweetId}',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(
    String message,
  ) {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                message,
              ),
              behavior:
                  SnackBarBehavior.floating,
            ),
          );

        ref
            .read(
              tweetsProvider.notifier,
            )
            .clearError();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final tweetsState =
        ref.watch(
      tweetsProvider,
    );

    final tweets =
        tweetsState.tweets;

    final error =
        tweetsState.error;

    if (error != null &&
        error.trim().isNotEmpty) {
      _showError(
        error,
      );
    }

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      floatingActionButton:
          FloatingActionButton(
        onPressed:
            tweetsState.creatingTweet
                ? null
                : openCreateTweetScreen,
        backgroundColor:
            colorScheme.onSurface,
        foregroundColor:
            colorScheme.surface,
        shape:
            const CircleBorder(),
        child:
            tweetsState.creatingTweet
                ? SizedBox(
                    width: R.size(
                      context,
                      22,
                    ),
                    height: R.size(
                      context,
                      22,
                    ),
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color:
                          colorScheme.surface,
                    ),
                  )
                : const Icon(
                    Icons.add,
                  ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FeedHeader(
              loading:
                  tweetsState.feedLoading,
              onRefresh:
                  _refreshFeed,
            ),
            Expanded(
              child: _FeedContent(
                tweets:
                    tweets,
                loading:
                    tweetsState.feedLoading,
                loadingMore:
                    tweetsState
                        .feedLoadingMore,
                scrollController:
                    _scrollController,
                onRefresh:
                    _refreshFeed,
                onTweetTap:
                    openTweetDetails,
                onCommentTap:
                    addQuickReply,
                onRetweetTap:
                    toggleRetweet,
                onLikeTap:
                    toggleLike,
                onDeleteTap:
                    deleteTweet,
                onShareTap:
                    shareTweet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
        .removeListener(
      _onScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }
}

class _FeedHeader
    extends StatelessWidget {
  final bool loading;

  final Future<void> Function()
      onRefresh;

  const _FeedHeader({
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      height: R.size(
        context,
        58,
      ),
      padding:
          EdgeInsets.symmetric(
        horizontal: R.size(
          context,
          16,
        ),
      ),
      decoration: BoxDecoration(
        color:
            theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme
                .outlineVariant
                .withValues(
                  alpha: 0.45,
                ),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Feed',
            style: TextStyle(
              color:
                  colorScheme.onSurface,
              fontSize:
                  R.sp(
                context,
                24,
              ),
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed:
                loading
                    ? null
                    : () {
                        onRefresh();
                      },
            icon:
                loading
                    ? SizedBox(
                        width: R.size(
                          context,
                          20,
                        ),
                        height: R.size(
                          context,
                          20,
                        ),
                        child:
                            const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                      ),
          ),
        ],
      ),
    );
  }
}

class _FeedContent
    extends StatelessWidget {
  final List<TweetModel> tweets;

  final bool loading;
  final bool loadingMore;

  final ScrollController
      scrollController;

  final Future<void> Function()
      onRefresh;

  final void Function(
    TweetModel tweet,
  ) onTweetTap;

  final void Function(
    TweetModel tweet,
  ) onCommentTap;

  final void Function(
    TweetModel tweet,
  ) onRetweetTap;

  final void Function(
    TweetModel tweet,
  ) onLikeTap;

  final void Function(
    TweetModel tweet,
  ) onDeleteTap;

  final void Function(
    TweetModel tweet,
  ) onShareTap;

  const _FeedContent({
    required this.tweets,
    required this.loading,
    required this.loadingMore,
    required this.scrollController,
    required this.onRefresh,
    required this.onTweetTap,
    required this.onCommentTap,
    required this.onRetweetTap,
    required this.onLikeTap,
    required this.onDeleteTap,
    required this.onShareTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading &&
        tweets.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (tweets.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            onRefresh,
        child: ListView(
          controller:
              scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.sizeOf(
                        context,
                      ).height *
                      0.25,
            ),
            const Icon(
              Icons.forum_outlined,
              size: 52,
            ),
            SizedBox(
              height: R.size(
                context,
                12,
              ),
            ),
            const Center(
              child: Text(
                'No tweets yet',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          onRefresh,
      child: ListView.builder(
        controller:
            scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.zero,
        itemCount:
            tweets.length +
            (loadingMore ? 1 : 0),
        itemBuilder: (
          context,
          index,
        ) {
          if (index >=
              tweets.length) {
            return Padding(
              padding:
                  EdgeInsets.all(
                R.size(
                  context,
                  20,
                ),
              ),
              child: const Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          final tweet =
              tweets[index];

          return TweetCard(
            tweet:
                tweet,
            onTap: () {
              onTweetTap(
                tweet,
              );
            },
            onCommentTap: () {
              onCommentTap(
                tweet,
              );
            },
            onRetweetTap: () {
              onRetweetTap(
                tweet,
              );
            },
            onLikeTap: () {
              onLikeTap(
                tweet,
              );
            },
            onDeleteTap: () {
              onDeleteTap(
                tweet,
              );
            },
            onShareTap: () {
              onShareTap(
                tweet,
              );
            },
          );
        },
      ),
    );
  }
}