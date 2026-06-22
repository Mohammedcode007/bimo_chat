import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../data/tweet_models.dart';
import '../logic/tweets_provider.dart';
import 'widgets/mention_text.dart';
import 'widgets/tweet_actions_bar.dart';
import 'widgets/tweet_media_preview.dart';

class TweetDetailsScreen extends ConsumerStatefulWidget {
  final TweetModel tweet;

  const TweetDetailsScreen({
    super.key,
    required this.tweet,
  });

  @override
  ConsumerState<TweetDetailsScreen> createState() =>
      _TweetDetailsScreenState();
}

class _TweetDetailsScreenState
    extends ConsumerState<TweetDetailsScreen> {
  final TextEditingController replyController =
      TextEditingController();

  final FocusNode replyFocusNode =
      FocusNode();

  final ScrollController scrollController =
      ScrollController();

  bool get canReply =>
      replyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    replyController.addListener(
      _onReplyTextChanged,
    );

    scrollController.addListener(
      _onScroll,
    );

    Future.microtask(
      _loadTweetData,
    );
  }

  void _onReplyTextChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _loadTweetData() {
    final controller =
        ref.read(tweetsProvider.notifier);

    controller.registerView(
      tweetId: widget.tweet.tweetId,
    );

    controller.loadTweetDetails(
      tweetId: widget.tweet.tweetId,
    );

    controller.loadComments(
      tweetId: widget.tweet.tweetId,
      refresh: true,
    );
  }

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    final position =
        scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 250) {
      ref
          .read(tweetsProvider.notifier)
          .loadComments(
            tweetId: widget.tweet.tweetId,
            refresh: false,
          );
    }
  }

  void focusReplyInput() {
    replyFocusNode.requestFocus();
  }

  void addReply() {
    final text =
        replyController.text.trim();

    if (text.isEmpty) {
      return;
    }

    ref
        .read(tweetsProvider.notifier)
        .createComment(
          tweetId: widget.tweet.tweetId,
          text: text,
        );

    replyController.clear();
    replyFocusNode.unfocus();
  }

  void toggleLike(
    TweetModel tweet,
  ) {
    ref
        .read(tweetsProvider.notifier)
        .toggleLike(
          tweetId: tweet.tweetId,
        );
  }

  void toggleRetweet(
    TweetModel tweet,
  ) {
    ref
        .read(tweetsProvider.notifier)
        .toggleRetweet(
          tweetId: tweet.tweetId,
        );
  }

  void shareTweet(
    TweetModel tweet,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Tweet ID: ${tweet.tweetId}',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  void deleteComment(
    TweetCommentModel comment,
  ) {
    ref
        .read(tweetsProvider.notifier)
        .deleteComment(
          commentId: comment.commentId,
        );
  }

  void editComment(
    TweetCommentModel comment,
  ) {
    final editController =
        TextEditingController(
      text: comment.text,
    );

    showDialog<void>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Edit comment',
          ),
          content: TextField(
            controller:
                editController,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            maxLength: 500,
            decoration:
                const InputDecoration(
              hintText:
                  'Edit your comment',
            ),
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
                final text =
                    editController.text
                        .trim();

                if (text.isEmpty) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop();

                ref
                    .read(
                      tweetsProvider.notifier,
                    )
                    .updateComment(
                      commentId:
                          comment.commentId,
                      text: text,
                    );
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    ).whenComplete(
      editController.dispose,
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
        ref.watch(tweetsProvider);

    final selectedTweet =
        tweetsState.selectedTweet;

    final tweet =
        selectedTweet?.tweetId ==
                widget.tweet.tweetId
            ? selectedTweet!
            : _findTweetInFeed(
                  tweetsState.tweets,
                ) ??
                widget.tweet;

    final comments =
        tweetsState.commentsByTweet[
              tweet.tweetId
            ] ??
            const <TweetCommentModel>[];

    final error =
        tweetsState.error;

    if (error != null &&
        error.trim().isNotEmpty) {
      _showError(error);
    }

    final tweetPending =
        tweetsState.pendingTweetIds
            .contains(
              tweet.tweetId,
            );

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            theme.scaffoldBackgroundColor,
        foregroundColor:
            colorScheme.onSurface,
        title: Text(
          'Post',
          style: TextStyle(
            color:
                colorScheme.onSurface,
            fontSize:
                R.sp(context, 21),
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadTweetData();

                await Future<void>.delayed(
                  const Duration(
                    milliseconds: 400,
                  ),
                );
              },
              child: ListView(
                controller:
                    scrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    EdgeInsets.zero,
                children: [
                  _TweetDetailsMain(
                    tweet: tweet,
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional
                            .fromSTEB(
                      R.size(context, 16),
                      R.size(context, 8),
                      R.size(context, 16),
                      R.size(context, 8),
                    ),
                    child: TweetActionsBar(
                      tweet: tweet,
                      onCommentTap:
                          focusReplyInput,
                      onRetweetTap:
                          tweetPending
                              ? () {}
                              : () {
                                  toggleRetweet(
                                    tweet,
                                  );
                                },
                      onLikeTap:
                          tweetPending
                              ? () {}
                              : () {
                                  toggleLike(
                                    tweet,
                                  );
                                },
                      onShareTap: () {
                        shareTweet(
                          tweet,
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme
                        .outlineVariant
                        .withValues(
                          alpha: 0.55,
                        ),
                  ),
                  if (comments.isEmpty)
                    _EmptyComments(
                      loading:
                          tweetPending,
                    )
                  else
                    ...comments.map(
                      (
                        comment,
                      ) {
                        final pending =
                            tweetsState
                                .pendingCommentIds
                                .contains(
                                  comment.commentId,
                                );

                        return _CommentTile(
                          comment:
                              comment,
                          pending:
                              pending,
                          onEdit: () {
                            editComment(
                              comment,
                            );
                          },
                          onDelete: () {
                            deleteComment(
                              comment,
                            );
                          },
                        );
                      },
                    ),
                  if (_hasMoreComments(
                    tweetsState
                        .commentsCursorByTweet[
                      tweet.tweetId
                    ],
                  ))
                    Padding(
                      padding:
                          EdgeInsets.all(
                        R.size(
                          context,
                          18,
                        ),
                      ),
                      child: const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  SizedBox(
                    height:
                        R.size(
                      context,
                      12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ReplyInput(
            controller:
                replyController,
            focusNode:
                replyFocusNode,
            canReply:
                canReply &&
                !tweetPending,
            onSend:
                addReply,
          ),
        ],
      ),
    );
  }

  TweetModel? _findTweetInFeed(
    List<TweetModel> tweets,
  ) {
    for (final tweet in tweets) {
      if (tweet.tweetId ==
          widget.tweet.tweetId) {
        return tweet;
      }
    }

    return null;
  }

  bool _hasMoreComments(
    String? cursor,
  ) {
    return cursor != null &&
        cursor.trim().isNotEmpty &&
        cursor != 'null';
  }

  @override
  void dispose() {
    replyController.removeListener(
      _onReplyTextChanged,
    );

    replyController.dispose();
    replyFocusNode.dispose();

    scrollController.removeListener(
      _onScroll,
    );

    scrollController.dispose();

    super.dispose();
  }
}

class _TweetDetailsMain
    extends StatelessWidget {
  final TweetModel tweet;

  const _TweetDetailsMain({
    required this.tweet,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final username =
        tweet.author?.username.trim() ??
        '';

    final avatarUrl =
        tweet.author?.photoUrl.trim() ??
        '';

    final userId =
        tweet.author?.userId.trim() ??
        '';

    return Padding(
      padding:
          EdgeInsetsDirectional.fromSTEB(
        R.size(context, 16),
        R.size(context, 12),
        R.size(context, 16),
        R.size(context, 10),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius:
                    R.size(context, 25),
                backgroundColor:
                    colorScheme
                        .surfaceContainerHighest,
                child: avatarUrl.isNotEmpty
                    ? ClipOval(
                        child:
                            Image.network(
                          avatarUrl,
                          width:
                              R.size(
                            context,
                            50,
                          ),
                          height:
                              R.size(
                            context,
                            50,
                          ),
                          fit:
                              BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return _AvatarText(
                              username:
                                  username,
                            );
                          },
                        ),
                      )
                    : _AvatarText(
                        username:
                            username,
                      ),
              ),
              SizedBox(
                width:
                    R.size(context, 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            username.isEmpty
                                ? 'Unknown user'
                                : username,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              color:
                                  colorScheme
                                      .onSurface,
                              fontSize:
                                  R.sp(
                                context,
                                17,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ),
                        if (_isVerified(
                          tweet,
                        )) ...[
                          SizedBox(
                            width:
                                R.size(
                              context,
                              4,
                            ),
                          ),
                          Icon(
                            Icons
                                .verified_rounded,
                            color:
                                const Color(
                              0xFF1D9BF0,
                            ),
                            size:
                                R.size(
                              context,
                              17,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      userId.isEmpty
                          ? ''
                          : '@$userId',
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontSize:
                            R.sp(
                          context,
                          15,
                        ),
                        fontWeight:
                            FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tweet.text
              .trim()
              .isNotEmpty) ...[
            SizedBox(
              height:
                  R.size(context, 14),
            ),
            MentionText(
              text:
                  tweet.text,
              fontSize: 22,
              color:
                  colorScheme.onSurface,
              fontWeight:
                  FontWeight.w400,
            ),
          ],
          TweetMediaPreview(
            tweet: tweet,
          ),
          SizedBox(
            height:
                R.size(context, 14),
          ),
          Text(
            _formatFullDate(
              tweet.createdAt,
            ),
            style: TextStyle(
              color: colorScheme
                  .onSurfaceVariant,
              fontSize:
                  R.sp(context, 15),
              fontWeight:
                  FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  bool _isVerified(
    TweetModel tweet,
  ) {
    final type =
        tweet.author
                ?.verificationType
                .trim()
                .toLowerCase() ??
            '';

    return type.isNotEmpty &&
        type != 'none' &&
        type != 'false' &&
        type != '0';
  }
}

class _AvatarText
    extends StatelessWidget {
  final String username;

  const _AvatarText({
    required this.username,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cleanName =
        username.trim();

    return Text(
      cleanName.isEmpty
          ? '?'
          : cleanName.characters
              .first
              .toUpperCase(),
      style: TextStyle(
        color: Theme.of(context)
            .colorScheme
            .onSurface,
        fontSize:
            R.sp(context, 18),
        fontWeight:
            FontWeight.w900,
      ),
    );
  }
}

class _CommentTile
    extends StatelessWidget {
  final TweetCommentModel comment;
  final bool pending;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.pending,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final username =
        comment.author?.username
            .trim() ??
        '';

    final userId =
        comment.author?.userId
            .trim() ??
        '';

    final avatarUrl =
        comment.author?.photoUrl
            .trim() ??
        '';

    return Opacity(
      opacity:
          pending ? 0.55 : 1,
      child: Container(
        padding:
            EdgeInsetsDirectional
                .fromSTEB(
          R.size(context, 16),
          R.size(context, 12),
          R.size(context, 8),
          R.size(context, 12),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme
                  .outlineVariant
                  .withValues(
                    alpha: 0.55,
                  ),
              width: 0.7,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius:
                  R.size(context, 22),
              backgroundColor:
                  colorScheme
                      .surfaceContainerHighest,
              child:
                  avatarUrl.isNotEmpty
                  ? ClipOval(
                      child:
                          Image.network(
                        avatarUrl,
                        width:
                            R.size(
                          context,
                          44,
                        ),
                        height:
                            R.size(
                          context,
                          44,
                        ),
                        fit:
                            BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return _AvatarText(
                            username:
                                username,
                          );
                        },
                      ),
                    )
                  : _AvatarText(
                      username:
                          username,
                    ),
            ),
            SizedBox(
              width:
                  R.size(context, 11),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          username.isEmpty
                              ? 'Unknown user'
                              : username,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color:
                                colorScheme
                                    .onSurface,
                            fontSize:
                                R.sp(
                              context,
                              16,
                            ),
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        width:
                            R.size(
                          context,
                          5,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _commentInfo(
                            userId:
                                userId,
                            date: comment
                                .createdAt,
                            isEdited:
                                comment
                                    .isEdited,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color:
                                colorScheme
                                    .onSurfaceVariant,
                            fontSize:
                                R.sp(
                              context,
                              14,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton<
                          String>(
                        padding:
                            EdgeInsets.zero,
                        enabled:
                            !pending,
                        icon: Icon(
                          Icons
                              .more_horiz_rounded,
                          size:
                              R.size(
                            context,
                            19,
                          ),
                          color:
                              colorScheme
                                  .onSurfaceVariant,
                        ),
                        onSelected: (
                          value,
                        ) {
                          if (value ==
                              'edit') {
                            onEdit();
                          }

                          if (value ==
                              'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder:
                            (context) {
                          return const [
                            PopupMenuItem<
                                String>(
                              value:
                                  'edit',
                              child:
                                  Text(
                                'Edit',
                              ),
                            ),
                            PopupMenuItem<
                                String>(
                              value:
                                  'delete',
                              child:
                                  Text(
                                'Delete',
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .red,
                                ),
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height:
                        R.size(
                      context,
                      4,
                    ),
                  ),
                  MentionText(
                    text:
                        comment.text,
                    fontSize: 17,
                    color:
                        colorScheme
                            .onSurface,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _commentInfo({
    required String userId,
    required DateTime? date,
    required bool isEdited,
  }) {
    final time =
        _formatRelativeTime(
      date,
    );

    final parts =
        <String>[];

    if (userId.isNotEmpty) {
      parts.add(
        '@$userId',
      );
    }

    if (time.isNotEmpty) {
      parts.add(
        time,
      );
    }

    if (isEdited) {
      parts.add(
        'edited',
      );
    }

    return parts.join(
      ' · ',
    );
  }
}

class _EmptyComments
    extends StatelessWidget {
  final bool loading;

  const _EmptyComments({
    required this.loading,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return Padding(
        padding:
            EdgeInsets.all(
          R.size(context, 24),
        ),
        child: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding:
          EdgeInsets.symmetric(
        vertical:
            R.size(context, 30),
        horizontal:
            R.size(context, 16),
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .chat_bubble_outline_rounded,
            size:
                R.size(context, 38),
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
          SizedBox(
            height:
                R.size(context, 10),
          ),
          Text(
            'No comments yet',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
              fontSize:
                  R.sp(context, 15),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyInput
    extends StatelessWidget {
  final TextEditingController
      controller;

  final FocusNode focusNode;

  final bool canReply;
  final VoidCallback onSend;

  const _ReplyInput({
    required this.controller,
    required this.focusNode,
    required this.canReply,
    required this.onSend,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding:
            EdgeInsetsDirectional
                .fromSTEB(
          R.size(context, 12),
          R.size(context, 8),
          R.size(context, 12),
          R.size(context, 8),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: colorScheme
                  .outlineVariant
                  .withValues(
                    alpha: 0.55,
                  ),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller:
                    controller,
                focusNode:
                    focusNode,
                minLines: 1,
                maxLines: 4,
                maxLength: 500,
                textInputAction:
                    TextInputAction
                        .newline,
                style: TextStyle(
                  color:
                      colorScheme
                          .onSurface,
                  fontSize:
                      R.sp(
                    context,
                    18,
                  ),
                ),
                decoration:
                    const InputDecoration(
                  hintText:
                      'Post your reply',
                  border:
                      InputBorder.none,
                  enabledBorder:
                      InputBorder.none,
                  focusedBorder:
                      InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
            IconButton(
              onPressed:
                  canReply
                      ? onSend
                      : null,
              icon: Icon(
                Icons.send_rounded,
                color: canReply
                    ? const Color(
                        0xFF1D9BF0,
                      )
                    : colorScheme
                        .onSurfaceVariant
                        .withValues(
                          alpha: 0.25,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRelativeTime(
  DateTime? date,
) {
  if (date == null) {
    return '';
  }

  final value =
      date.toLocal();

  final difference =
      DateTime.now().difference(
    value,
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

  if (difference.inDays < 7) {
    return '${difference.inDays}d';
  }

  return '${value.day}/${value.month}/${value.year}';
}

String _formatFullDate(
  DateTime? date,
) {
  if (date == null) {
    return '';
  }

  final value =
      date.toLocal();

  final hour =
      value.hour
          .toString()
          .padLeft(
            2,
            '0',
          );

  final minute =
      value.minute
          .toString()
          .padLeft(
            2,
            '0',
          );

  final day =
      value.day
          .toString()
          .padLeft(
            2,
            '0',
          );

  final month =
      value.month
          .toString()
          .padLeft(
            2,
            '0',
          );

  return '$hour:$minute · $day/$month/${value.year}';
}