import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/responsive.dart';
import '../data/tweet_model.dart';

class TweetCreateResult {
  final String text;
  final TweetMediaType mediaType;
  final String? mediaPath;

  const TweetCreateResult({
    required this.text,
    required this.mediaType,
    this.mediaPath,
  });
}

class TweetCreateScreen extends StatefulWidget {
  final void Function(TweetCreateResult result) onPost;

  const TweetCreateScreen({super.key, required this.onPost});

  @override
  State<TweetCreateScreen> createState() => _TweetCreateScreenState();
}

class _TweetCreateScreenState extends State<TweetCreateScreen> {
  final controller = TextEditingController();
  final imagePicker = ImagePicker();

  TweetMediaType selectedMediaType = TweetMediaType.none;
  String? selectedMediaPath;

  bool get canPost {
    return controller.text.trim().isNotEmpty || selectedMediaPath != null;
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      selectedMediaType = TweetMediaType.image;
      selectedMediaPath = image.path;
    });
  }

  Future<void> pickVideo() async {
    final video = await imagePicker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 3),
    );

    if (video == null) return;

    setState(() {
      selectedMediaType = TweetMediaType.video;
      selectedMediaPath = video.path;
    });
  }

  void removeMedia() {
    setState(() {
      selectedMediaType = TweetMediaType.none;
      selectedMediaPath = null;
    });
  }

  void post() {
    if (!canPost) return;

    widget.onPost(
      TweetCreateResult(
        text: controller.text.trim(),
        mediaType: selectedMediaType,
        mediaPath: selectedMediaPath,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: R.size(context, 14)),
            child: Center(
              child: ElevatedButton(
                onPressed: canPost ? post : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  disabledBackgroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.25,
                  ),
                  disabledForegroundColor: colorScheme.surface.withValues(
                    alpha: 0.65,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Post'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 16),
                R.size(context, 8),
                R.size(context, 16),
                R.size(context, 16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: R.size(context, 24),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 18),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  SizedBox(width: R.size(context, 12)),

                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          autofocus: true,
                          minLines: 5,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: R.sp(context, 21),
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'What is happening?!',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.38,
                              ),
                              fontSize: R.sp(context, 21),
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                        if (selectedMediaPath != null)
                          _SelectedMediaPreview(
                            mediaPath: selectedMediaPath!,
                            mediaType: selectedMediaType,
                            onRemove: removeMedia,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _CreateBottomBar(onPickImage: pickImage, onPickVideo: pickVideo),
        ],
      ),
    );
  }
}

class _SelectedMediaPreview extends StatelessWidget {
  final String mediaPath;
  final TweetMediaType mediaType;
  final VoidCallback onRemove;

  const _SelectedMediaPreview({
    required this.mediaPath,
    required this.mediaType,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.size(context, 16)),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(mediaPath), fit: BoxFit.cover),

              if (mediaType == TweetMediaType.video)
                Container(color: Colors.black.withValues(alpha: 0.22)),

              if (mediaType == TweetMediaType.video)
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

              PositionedDirectional(
                top: R.size(context, 8),
                end: R.size(context, 8),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: R.size(context, 34),
                    height: R.size(context, 34),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: R.size(context, 22),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(R.size(context, 16)),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
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

class _CreateBottomBar extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;

  const _CreateBottomBar({
    required this.onPickImage,
    required this.onPickVideo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        height: R.size(context, 58),
        padding: EdgeInsets.symmetric(horizontal: R.size(context, 14)),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onPickImage,
              icon: Icon(
                Icons.image_outlined,
                color: const Color(0xFF1D9BF0),
                size: R.size(context, 28),
              ),
            ),

            IconButton(
              onPressed: onPickVideo,
              icon: Icon(
                Icons.video_library_outlined,
                color: const Color(0xFF1D9BF0),
                size: R.size(context, 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
