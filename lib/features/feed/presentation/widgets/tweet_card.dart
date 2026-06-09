import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/tweet_model.dart';
import 'mention_text.dart';
import 'tweet_actions_bar.dart';
import 'tweet_media_preview.dart';

class TweetCard extends StatelessWidget {
  final TweetModel tweet;
  final VoidCallback onTap;
  final VoidCallback onCommentTap;
  final VoidCallback onRepostTap;
  final VoidCallback onLikeTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onShareTap;

  const TweetCard({
    super.key,
    required this.tweet,
    required this.onTap,
    required this.onCommentTap,
    required this.onRepostTap,
    required this.onLikeTap,
    required this.onDeleteTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 14),
          R.size(context, 13),
          R.size(context, 12),
          R.size(context, 10),
        ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(tweet: tweet),

            SizedBox(width: R.size(context, 11)),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: R.size(context, 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TweetHeader(tweet: tweet, onDeleteTap: onDeleteTap),

                    if (tweet.text.trim().isNotEmpty) ...[
                      SizedBox(height: R.size(context, 5)),
                      MentionText(
                        text: tweet.text,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ],

                    TweetMediaPreview(tweet: tweet),

                    TweetActionsBar(
                      tweet: tweet,
                      onCommentTap: onCommentTap,
                      onRepostTap: onRepostTap,
                      onLikeTap: onLikeTap,
                      onShareTap: onShareTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final TweetModel tweet;

  const _Avatar({required this.tweet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: R.size(context, 24),
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: tweet.avatarUrl.trim().isNotEmpty
          ? ClipOval(
              child: Image.network(
                tweet.avatarUrl,
                width: R.size(context, 48),
                height: R.size(context, 48),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _AvatarFallback(tweet: tweet);
                },
              ),
            )
          : _AvatarFallback(tweet: tweet),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final TweetModel tweet;

  const _AvatarFallback({required this.tweet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      tweet.authorName.isEmpty ? '?' : tweet.authorName[0].toUpperCase(),
      style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.75),
        fontSize: R.sp(context, 18),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TweetHeader extends StatelessWidget {
  final TweetModel tweet;
  final VoidCallback onDeleteTap;

  const _TweetHeader({required this.tweet, required this.onDeleteTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: R.size(context, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              tweet.authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: R.sp(context, 17),
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),

          SizedBox(width: R.size(context, 5)),

          Flexible(
            child: Text(
              '@${tweet.username} · ${tweet.time}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: R.sp(context, 15.5),
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),

          SizedBox(width: R.size(context, 2)),

          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: colorScheme.surface,
            icon: Icon(
              Icons.more_horiz_rounded,
              size: R.size(context, 21),
              color: colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              if (value == 'delete') {
                onDeleteTap();
              }
            },
            itemBuilder: (_) {
              return [
                if (tweet.isMine)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Tweet'),
                  )
                else
                  const PopupMenuItem(value: 'report', child: Text('Report')),
              ];
            },
          ),
        ],
      ),
    );
  }
}
