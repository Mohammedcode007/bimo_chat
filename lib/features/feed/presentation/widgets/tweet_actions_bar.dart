import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/tweet_models.dart';

class TweetActionsBar extends StatelessWidget {
  final TweetModel tweet;

  final VoidCallback onCommentTap;
  final VoidCallback onRetweetTap;
  final VoidCallback onLikeTap;
  final VoidCallback onShareTap;

  const TweetActionsBar({
    super.key,
    required this.tweet,
    required this.onCommentTap,
    required this.onRetweetTap,
    required this.onLikeTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: R.size(context, 10),
      ),
      child: Row(
        children: [
          /*
            عدد التعليقات الحقيقي.
          */
          _ActionItem(
            icon: Icons.mode_comment_outlined,
            value: tweet.commentsCount,
            onTap: onCommentTap,
          ),

          const Spacer(),

          /*
            الريتويت الحقيقي.
          */
          _ActionItem(
            icon: Icons.repeat_rounded,
            value: tweet.retweetsCount,
            color: tweet.isRetweeted
                ? const Color(0xFF00BA7C)
                : null,
            onTap: onRetweetTap,
          ),

          const Spacer(),

          /*
            الإعجاب الحقيقي.
          */
          _ActionItem(
            icon: tweet.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            value: tweet.likesCount,
            color: tweet.isLiked
                ? const Color(0xFFF91880)
                : null,
            onTap: onLikeTap,
          ),

          const Spacer(),

          /*
            عدد المشاهدات الحقيقي.
          */
          _ActionItem(
            icon: Icons.bar_chart_rounded,
            value: tweet.viewsCount,

            /*
              لا نزيد المشاهدة عند الضغط هنا.
              المشاهدة تُسجل عند ظهور التويتة للمستخدم.
            */
            onTap: () {},
          ),

          const Spacer(),

          InkWell(
            onTap: onShareTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.all(
                R.size(context, 6),
              ),
              child: Icon(
                Icons.ios_share_rounded,
                size: R.size(context, 18),
                color: Colors.black.withValues(
                  alpha: 0.52,
                ),
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
    final currentColor =
        color ??
        Colors.black.withValues(
          alpha: 0.52,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.size(context, 4),
          vertical: R.size(context, 6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: R.size(context, 18),
              color: currentColor,
            ),
            if (value > 0) ...[
              SizedBox(
                width: R.size(context, 4),
              ),
              Text(
                formatCount(value),
                style: TextStyle(
                  color: currentColor,
                  fontSize: R.sp(context, 13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      final value = count / 1000000;

      return value % 1 == 0
          ? '${value.toInt()}M'
          : '${value.toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      final value = count / 1000;

      return value % 1 == 0
          ? '${value.toInt()}K'
          : '${value.toStringAsFixed(1)}K';
    }

    return count.toString();
  }
}