import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/tweet_models.dart';

class TweetMediaPreview extends StatelessWidget {
  final TweetModel tweet;

  const TweetMediaPreview({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context) {
    final validMedia = tweet.media
        .where(
          (item) => item.url.trim().isNotEmpty,
        )
        .toList();

    if (validMedia.isEmpty ||
        tweet.mediaType == 'none') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: R.size(context, 10),
      ),
      child: _TweetMediaContent(
        media: validMedia,
        mediaType: tweet.mediaType,
      ),
    );
  }
}

class _TweetMediaContent extends StatelessWidget {
  final List<TweetMediaModel> media;
  final String mediaType;

  const _TweetMediaContent({
    required this.media,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo =
        mediaType == 'video' ||
        media.any(
          (item) => item.isVideo,
        );

    if (isVideo) {
      final video = media.firstWhere(
        (item) => item.isVideo,
        orElse: () => media.first,
      );

      return _VideoPreview(
        media: video,
      );
    }

    return _ImagesPreview(
      media: media.take(4).toList(),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  final TweetMediaModel media;

  const _VideoPreview({
    required this.media,
  });

  void _openVideo(
    BuildContext context,
  ) {
    final videoUrl =
        media.url.trim();

    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'رابط الفيديو غير موجود',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return _TweetVideoPlayerScreen(
            videoUrl: videoUrl,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final previewUrl =
        media.thumbnailUrl.trim().isNotEmpty
            ? media.thumbnailUrl.trim()
            : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        R.size(context, 16),
      ),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: () {
            _openVideo(context);
          },
          child: AspectRatio(
            aspectRatio: _mediaAspectRatio(
              media,
              fallback: 16 / 10,
            ),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                if (previewUrl.isNotEmpty)
                  _NetworkMediaImage(
                    url: previewUrl,
                  )
                else
                  Container(
                    color: Colors.black,
                    alignment:
                        Alignment.center,
                    child: Icon(
                      Icons
                          .video_library_outlined,
                      color: Colors.white54,
                      size: R.size(
                        context,
                        72,
                      ),
                    ),
                  ),

                Container(
                  color: Colors.black.withValues(
                    alpha: 0.20,
                  ),
                ),

                Center(
                  child: Container(
                    width:
                        R.size(context, 60),
                    height:
                        R.size(context, 60),
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withValues(
                        alpha: 0.68,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white
                            .withValues(
                          alpha: 0.80,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size:
                          R.size(context, 44),
                    ),
                  ),
                ),

                PositionedDirectional(
                  start:
                      R.size(context, 10),
                  bottom:
                      R.size(context, 10),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal:
                          R.size(context, 8),
                      vertical:
                          R.size(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withValues(
                        alpha: 0.72,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        R.size(context, 8),
                      ),
                    ),
                    child: Text(
                      _videoLabel(media),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            R.sp(context, 12),
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme
                              .outlineVariant
                              .withValues(
                            alpha: 0.55,
                          ),
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          R.size(context, 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _videoLabel(
    TweetMediaModel media,
  ) {
    final duration =
        media.duration;

    if (duration == null ||
        duration <= 0) {
      return 'Video';
    }

    final totalSeconds =
        duration.round();

    final minutes =
        totalSeconds ~/ 60;

    final seconds =
        totalSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _TweetVideoPlayerScreen
    extends StatefulWidget {
  final String videoUrl;

  const _TweetVideoPlayerScreen({
    required this.videoUrl,
  });

  @override
  State<_TweetVideoPlayerScreen> createState() =>
      _TweetVideoPlayerScreenState();
}

class _TweetVideoPlayerScreenState
    extends State<_TweetVideoPlayerScreen> {
  VideoPlayerController? _controller;

  bool _initializing = true;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final cleanUrl =
        widget.videoUrl.trim();

    if (cleanUrl.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _initializing = false;
        _hasError = true;
      });

      return;
    }

    try {
      final uri =
          Uri.parse(cleanUrl);

      final controller =
          VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions:
            VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      _controller = controller;

      await controller.initialize();

      await controller.setLooping(false);
      await controller.play();

      controller.addListener(
        _videoListener,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _initializing = false;
        _hasError = false;
      });
    } catch (error) {
      debugPrint(
        'TWEET VIDEO INITIALIZE ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _initializing = false;
        _hasError = true;
      });
    }
  }

  void _videoListener() {
    if (!mounted) {
      return;
    }

    final controller =
        _controller;

    if (controller == null) {
      return;
    }

    if (controller.value.hasError) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    final controller =
        _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      final position =
          controller.value.position;

      final duration =
          controller.value.duration;

      if (duration > Duration.zero &&
          position >= duration) {
        await controller.seekTo(
          Duration.zero,
        );
      }

      await controller.play();
    }

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _toggleMute() async {
    final controller =
        _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    final muted =
        controller.value.volume <= 0;

    await controller.setVolume(
      muted ? 1 : 0,
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _toggleControls() {
    setState(() {
      _showControls =
          !_showControls;
    });
  }

  @override
  void dispose() {
    final controller =
        _controller;

    controller?.removeListener(
      _videoListener,
    );

    controller?.pause();
    controller?.dispose();

    _controller = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_initializing)
              const Center(
                child:
                    CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            else if (_hasError ||
                controller == null ||
                !controller
                    .value.isInitialized)
              _VideoErrorView(
                onRetry: () async {
                  final oldController =
                      _controller;

                  oldController
                      ?.removeListener(
                    _videoListener,
                  );

                  await oldController
                      ?.dispose();

                  _controller = null;

                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _initializing = true;
                    _hasError = false;
                  });

                  await _initializeVideo();
                },
              )
            else
              GestureDetector(
                behavior:
                    HitTestBehavior.opaque,
                onTap: _toggleControls,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller
                                .value
                                .aspectRatio >
                            0
                        ? controller
                            .value
                            .aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(
                      controller,
                    ),
                  ),
                ),
              ),

            if (!_initializing &&
                !_hasError &&
                controller != null &&
                controller
                    .value.isInitialized &&
                _showControls)
              _VideoControlsOverlay(
                controller: controller,
                onClose: () {
                  Navigator.of(context).pop();
                },
                onPlayPause:
                    _togglePlayPause,
                onMute: _toggleMute,
              )
            else
              PositionedDirectional(
                top: R.size(context, 8),
                start: R.size(context, 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Colors.black.withValues(
                      alpha: 0.45,
                    ),
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoControlsOverlay
    extends StatelessWidget {
  final VideoPlayerController controller;

  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onMute;

  const _VideoControlsOverlay({
    required this.controller,
    required this.onClose,
    required this.onPlayPause,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    final value =
        controller.value;

    final isPlaying =
        value.isPlaying;

    final isMuted =
        value.volume <= 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: Container(
            color: Colors.black.withValues(
              alpha: 0.16,
            ),
          ),
        ),

        PositionedDirectional(
          top: R.size(context, 8),
          start: R.size(context, 8),
          child: IconButton(
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor:
                  Colors.black.withValues(
                alpha: 0.52,
              ),
            ),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ),

        Center(
          child: IconButton(
            onPressed: onPlayPause,
            style: IconButton.styleFrom(
              backgroundColor:
                  Colors.black.withValues(
                alpha: 0.60,
              ),
              minimumSize: Size(
                R.size(context, 68),
                R.size(context, 68),
              ),
            ),
            icon: Icon(
              isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: R.size(context, 48),
            ),
          ),
        ),

        PositionedDirectional(
          end: R.size(context, 12),
          bottom: R.size(context, 46),
          child: IconButton(
            onPressed: onMute,
            style: IconButton.styleFrom(
              backgroundColor:
                  Colors.black.withValues(
                alpha: 0.52,
              ),
            ),
            icon: Icon(
              isMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              color: Colors.white,
            ),
          ),
        ),

        PositionedDirectional(
          start: R.size(context, 12),
          end: R.size(context, 12),
          bottom: R.size(context, 12),
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: EdgeInsets.symmetric(
              vertical: R.size(context, 8),
            ),
            colors:
                const VideoProgressColors(
              playedColor:
                  Color(0xFF1D9BF0),
              bufferedColor:
                  Colors.white38,
              backgroundColor:
                  Colors.white24,
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoErrorView
    extends StatelessWidget {
  final VoidCallback onRetry;

  const _VideoErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          R.size(context, 24),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .video_file_outlined,
              color: Colors.white70,
              size: R.size(context, 64),
            ),

            SizedBox(
              height: R.size(context, 14),
            ),

            Text(
              'تعذر تشغيل الفيديو',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    R.sp(context, 17),
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            SizedBox(
              height: R.size(context, 8),
            ),

            Text(
              'تحقق من رابط الفيديو أو اتصال الإنترنت',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize:
                    R.sp(context, 14),
              ),
            ),

            SizedBox(
              height: R.size(context, 18),
            ),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagesPreview extends StatelessWidget {
  final List<TweetMediaModel> media;

  const _ImagesPreview({
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    if (media.length == 1) {
      return _SingleImage(
        media: media.first,
      );
    }

    if (media.length == 2) {
      return _TwoImages(
        media: media,
      );
    }

    if (media.length == 3) {
      return _ThreeImages(
        media: media,
      );
    }

    return _FourImages(
      media: media,
    );
  }
}

class _SingleImage extends StatelessWidget {
  final TweetMediaModel media;

  const _SingleImage({
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return _MediaContainer(
      aspectRatio: _mediaAspectRatio(
        media,
        fallback: 16 / 10,
      ),
      child: _NetworkMediaImage(
        url: media.url,
      ),
    );
  }
}

class _TwoImages extends StatelessWidget {
  final List<TweetMediaModel> media;

  const _TwoImages({
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final gap =
        R.size(context, 2);

    return _MediaContainer(
      aspectRatio: 16 / 10,
      child: Row(
        children: [
          Expanded(
            child: _NetworkMediaImage(
              url: media[0].url,
            ),
          ),

          SizedBox(
            width: gap,
          ),

          Expanded(
            child: _NetworkMediaImage(
              url: media[1].url,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeImages extends StatelessWidget {
  final List<TweetMediaModel> media;

  const _ThreeImages({
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final gap =
        R.size(context, 2);

    return _MediaContainer(
      aspectRatio: 16 / 10,
      child: Row(
        children: [
          Expanded(
            child: _NetworkMediaImage(
              url: media[0].url,
            ),
          ),

          SizedBox(
            width: gap,
          ),

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child:
                      _NetworkMediaImage(
                    url:
                        media[1].url,
                  ),
                ),

                SizedBox(
                  height: gap,
                ),

                Expanded(
                  child:
                      _NetworkMediaImage(
                    url:
                        media[2].url,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FourImages extends StatelessWidget {
  final List<TweetMediaModel> media;

  const _FourImages({
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final gap =
        R.size(context, 2);

    return _MediaContainer(
      aspectRatio: 16 / 10,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child:
                      _NetworkMediaImage(
                    url:
                        media[0].url,
                  ),
                ),

                SizedBox(
                  width: gap,
                ),

                Expanded(
                  child:
                      _NetworkMediaImage(
                    url:
                        media[1].url,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: gap,
          ),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child:
                      _NetworkMediaImage(
                    url:
                        media[2].url,
                  ),
                ),

                SizedBox(
                  width: gap,
                ),

                Expanded(
                  child:
                      _NetworkMediaImage(
                    url:
                        media[3].url,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaContainer extends StatelessWidget {
  final double aspectRatio;
  final Widget child;

  const _MediaContainer({
    required this.aspectRatio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final radius =
        BorderRadius.circular(
      R.size(context, 16),
    );

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme
                          .outlineVariant
                          .withValues(
                        alpha: 0.55,
                      ),
                    ),
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkMediaImage extends StatelessWidget {
  final String url;

  const _NetworkMediaImage({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl =
        url.trim();

    if (cleanUrl.isEmpty) {
      return const _MediaErrorBox(
        text: 'Media not available',
      );
    }

    return Image.network(
      cleanUrl,
      fit: BoxFit.cover,
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        final expectedBytes =
            loadingProgress
                .expectedTotalBytes;

        final progress =
            expectedBytes == null ||
                    expectedBytes == 0
                ? null
                : loadingProgress
                          .cumulativeBytesLoaded /
                      expectedBytes;

        return _MediaLoadingBox(
          progress: progress,
        );
      },
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const _MediaErrorBox(
          text: 'Media not available',
        );
      },
    );
  }
}

class _MediaLoadingBox extends StatelessWidget {
  final double? progress;

  const _MediaLoadingBox({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      color: colorScheme
          .surfaceContainerHighest,
      alignment: Alignment.center,
      child: SizedBox(
        width: R.size(context, 24),
        height: R.size(context, 24),
        child:
            CircularProgressIndicator(
          strokeWidth: 2.5,
          value: progress,
        ),
      ),
    );
  }
}

class _MediaErrorBox extends StatelessWidget {
  final String text;

  const _MediaErrorBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      color: colorScheme
          .surfaceContainerHighest,
      alignment: Alignment.center,
      padding: EdgeInsets.all(
        R.size(context, 12),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons
                .broken_image_outlined,
            color: colorScheme
                .onSurfaceVariant,
            size:
                R.size(context, 27),
          ),

          SizedBox(
            height:
                R.size(context, 5),
          ),

          Text(
            text,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: colorScheme
                  .onSurfaceVariant,
              fontSize:
                  R.sp(context, 13),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

double _mediaAspectRatio(
  TweetMediaModel media, {
  required double fallback,
}) {
  final width =
      media.width;

  final height =
      media.height;

  if (width == null ||
      height == null ||
      width <= 0 ||
      height <= 0) {
    return fallback;
  }

  final ratio =
      width / height;

  return ratio.clamp(
    0.75,
    1.9,
  );
}