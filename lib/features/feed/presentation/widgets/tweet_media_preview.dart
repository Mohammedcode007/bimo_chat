import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/tweet_model.dart';

class TweetMediaPreview extends StatelessWidget {
  final TweetModel tweet;

  const TweetMediaPreview({super.key, required this.tweet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (tweet.mediaType == TweetMediaType.none || tweet.mediaUrl == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.size(context, 16)),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              _MediaImage(tweet: tweet),

              if (tweet.mediaType == TweetMediaType.video)
                Container(color: Colors.black.withValues(alpha: 0.20)),

              if (tweet.mediaType == TweetMediaType.video)
                Center(
                  child: Container(
                    width: R.size(context, 58),
                    height: R.size(context, 58),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: R.size(context, 42),
                    ),
                  ),
                ),

              if (tweet.mediaType == TweetMediaType.video)
                PositionedDirectional(
                  start: R.size(context, 10),
                  bottom: R.size(context, 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.size(context, 8),
                      vertical: R.size(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(R.size(context, 8)),
                    ),
                    child: Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: R.sp(context, 12),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                    borderRadius: BorderRadius.circular(R.size(context, 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaImage extends StatelessWidget {
  final TweetModel tweet;

  const _MediaImage({required this.tweet});

  @override
  Widget build(BuildContext context) {
    if (tweet.isLocalMedia && tweet.mediaUrl != null) {
      return Image.file(
        File(tweet.mediaUrl!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const _MediaErrorBox(text: 'Media not available');
        },
      );
    }

    return Image.network(
      tweet.mediaUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const _MediaErrorBox(text: 'Media not available');
      },
    );
  }
}

class _MediaErrorBox extends StatelessWidget {
  final String text;

  const _MediaErrorBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: R.sp(context, 14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
