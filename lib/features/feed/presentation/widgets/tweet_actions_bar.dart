import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/tweet_model.dart';

class TweetActionsBar extends StatelessWidget {
  final TweetModel tweet;
  final VoidCallback onCommentTap;
  final VoidCallback onRepostTap;
  final VoidCallback onLikeTap;
  final VoidCallback onShareTap;

  const TweetActionsBar({
    super.key,
    required this.tweet,
    required this.onCommentTap,
    required this.onRepostTap,
    required this.onLikeTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 10)),
      child: Row(
        children: [
          _ActionItem(
            icon: Icons.mode_comment_outlined,
            value: tweet.commentsCount,
            onTap: onCommentTap,
          ),
          const Spacer(),
          _ActionItem(
            icon: Icons.repeat_rounded,
            value: tweet.repostsCount,
            color: tweet.isReposted ? const Color(0xFF00BA7C) : null,
            onTap: onRepostTap,
          ),
          const Spacer(),
          _ActionItem(
            icon: tweet.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            value: tweet.likesCount,
            color: tweet.isLiked ? const Color(0xFFF91880) : null,
            onTap: onLikeTap,
          ),
          const Spacer(),
          _ActionItem(
            icon: Icons.bar_chart_rounded,
            value: tweet.viewsCount,
            onTap: () {},
          ),
          const Spacer(),
          InkWell(
            onTap: onShareTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.all(R.size(context, 6)),
              child: Icon(
                Icons.ios_share_rounded,
                size: R.size(context, 18),
                color: Colors.black.withValues(alpha: 0.52),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.value,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = color ?? Colors.black.withValues(alpha: 0.52);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.size(context, 4),
          vertical: R.size(context, 6),
        ),
        child: Row(
          children: [
            Icon(icon, size: R.size(context, 18), color: currentColor),
            SizedBox(width: R.size(context, 4)),
            Text(
              formatCount(value),
              style: TextStyle(
                color: currentColor,
                fontSize: R.sp(context, 13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }

    if (count == 0) {
      return '';
    }

    return '$count';
  }
}
