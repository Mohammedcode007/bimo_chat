import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/responsive.dart';

class TweetCreateResult {
  final String text;

  /*
    مسارات الصور المحلية قبل تحويلها إلى Base64.
    الحد الأقصى أربع صور.
  */
  final List<String> imagePaths;

  /*
    مسار الفيديو المحلي قبل تحويله إلى Base64.
    فيديو واحد فقط.
  */
  final String? videoPath;

  const TweetCreateResult({
    required this.text,
    this.imagePaths = const [],
    this.videoPath,
  });

  bool get hasImages =>
      imagePaths.isNotEmpty;

  bool get hasVideo =>
      videoPath != null &&
      videoPath!.trim().isNotEmpty;

  bool get hasMedia =>
      hasImages || hasVideo;
}

class TweetCreateScreen
    extends StatefulWidget {
  /*
    أصبحت Future حتى ننتظر:
    قراءة الملفات
    تحويلها إلى Base64
    إرسالها إلى WebSocket
  */
  final Future<void> Function(
    TweetCreateResult result,
  ) onPost;

  const TweetCreateScreen({
    super.key,
    required this.onPost,
  });

  @override
  State<TweetCreateScreen> createState() =>
      _TweetCreateScreenState();
}

class _TweetCreateScreenState
    extends State<TweetCreateScreen> {
  final TextEditingController controller =
      TextEditingController();

  final ImagePicker imagePicker =
      ImagePicker();

  final List<String>
      selectedImagePaths = [];

  String? selectedVideoPath;

  bool isPickingMedia = false;
  bool isPosting = false;

  bool get hasImages =>
      selectedImagePaths.isNotEmpty;

  bool get hasVideo =>
      selectedVideoPath != null &&
      selectedVideoPath!
          .trim()
          .isNotEmpty;

  bool get isBusy =>
      isPickingMedia || isPosting;

  bool get canPost {
    return controller.text
            .trim()
            .isNotEmpty ||
        hasImages ||
        hasVideo;
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(
      _onTextChanged,
    );
  }

  void _onTextChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(
      _onTextChanged,
    );

    controller.dispose();

    super.dispose();
  }

  Future<void> pickImages() async {
    if (isBusy) {
      return;
    }

    /*
      لا يمكن إضافة صور مع فيديو.
    */
    if (hasVideo) {
      _showMessage(
        'احذف الفيديو أولًا قبل اختيار الصور',
      );

      return;
    }

    if (selectedImagePaths.length >= 4) {
      _showMessage(
        'يمكن اختيار أربع صور فقط',
      );

      return;
    }

    setState(() {
      isPickingMedia = true;
    });

    try {
      final images =
          await imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isEmpty) {
        return;
      }

      final remaining =
          4 - selectedImagePaths.length;

      final selected = images
          .take(remaining)
          .map(
            (image) => image.path,
          )
          .where(
            (path) =>
                path.trim().isNotEmpty,
          )
          .toList(growable: false);

      if (!mounted) {
        return;
      }

      setState(() {
        for (final path in selected) {
          if (!selectedImagePaths
              .contains(path)) {
            selectedImagePaths.add(path);
          }
        }
      });

      if (images.length > remaining) {
        _showMessage(
          'تم اختيار أول $remaining صور فقط',
        );
      }
    } catch (error) {
      _showMessage(
        'تعذر اختيار الصور',
      );
    } finally {
      if (mounted) {
        setState(() {
          isPickingMedia = false;
        });
      }
    }
  }

  Future<void> pickVideo() async {
    if (isBusy) {
      return;
    }

    /*
      لا يمكن إضافة فيديو مع الصور.
    */
    if (hasImages) {
      _showMessage(
        'احذف الصور أولًا قبل اختيار الفيديو',
      );

      return;
    }

    setState(() {
      isPickingMedia = true;
    });

    try {
      final video =
          await imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration:
            const Duration(minutes: 3),
      );

      if (video == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        selectedVideoPath =
            video.path;
      });
    } catch (error) {
      _showMessage(
        'تعذر اختيار الفيديو',
      );
    } finally {
      if (mounted) {
        setState(() {
          isPickingMedia = false;
        });
      }
    }
  }

  void removeImage(
    String path,
  ) {
    if (isBusy) {
      return;
    }

    setState(() {
      selectedImagePaths.remove(path);
    });
  }

  void removeVideo() {
    if (isBusy) {
      return;
    }

    setState(() {
      selectedVideoPath = null;
    });
  }

  Future<void> post() async {
    if (!canPost || isBusy) {
      return;
    }

    FocusScope.of(context).unfocus();

    final result =
        TweetCreateResult(
      text: controller.text.trim(),
      imagePaths:
          List<String>.unmodifiable(
        selectedImagePaths,
      ),
      videoPath:
          selectedVideoPath,
    );

    setState(() {
      isPosting = true;
    });

    try {
      await widget.onPost(result);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          )
          .replaceFirst(
            'ArgumentError: ',
            '',
          )
          .trim();

      _showMessage(
        message.isEmpty
            ? 'تعذر نشر التويتة'
            : message,
      );
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
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

    return PopScope(
      canPop: !isPosting,
      child: Scaffold(
        backgroundColor:
            theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              theme.scaffoldBackgroundColor,
          foregroundColor:
              colorScheme.onSurface,
          leading: IconButton(
            onPressed: isPosting
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
          actions: [
            Padding(
              padding:
                  EdgeInsetsDirectional.only(
                end: R.size(
                  context,
                  14,
                ),
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed:
                      canPost && !isBusy
                          ? post
                          : null,
                  style:
                      ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        colorScheme.onSurface,
                    foregroundColor:
                        colorScheme.surface,
                    disabledBackgroundColor:
                        colorScheme.onSurface
                            .withValues(
                      alpha: 0.25,
                    ),
                    disabledForegroundColor:
                        colorScheme.surface
                            .withValues(
                      alpha: 0.65,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                  ),
                  child: isPosting
                      ? SizedBox(
                          width: R.size(
                            context,
                            18,
                          ),
                          height: R.size(
                            context,
                            18,
                          ),
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                colorScheme.surface,
                          ),
                        )
                      : const Text(
                          'Post',
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    EdgeInsetsDirectional
                        .fromSTEB(
                  R.size(context, 16),
                  R.size(context, 8),
                  R.size(context, 16),
                  R.size(context, 16),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius:
                          R.size(context, 24),
                      backgroundColor:
                          colorScheme
                              .surfaceContainerHighest,
                      child: Text(
                        'M',
                        style: TextStyle(
                          color:
                              colorScheme.onSurface,
                          fontSize:
                              R.sp(context, 18),
                          fontWeight:
                              FontWeight.w900,
                        ),
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
                          TextField(
                            controller:
                                controller,
                            enabled: !isPosting,
                            autofocus: true,
                            minLines: 5,
                            maxLines: null,
                            maxLength: 1000,
                            keyboardType:
                                TextInputType
                                    .multiline,
                            style: TextStyle(
                              color: colorScheme
                                  .onSurface,
                              fontSize:
                                  R.sp(
                                context,
                                21,
                              ),
                              height: 1.35,
                              fontWeight:
                                  FontWeight.w400,
                            ),
                            decoration:
                                InputDecoration(
                              hintText:
                                  'What is happening?!',
                              hintStyle:
                                  TextStyle(
                                color: colorScheme
                                    .onSurface
                                    .withValues(
                                  alpha: 0.38,
                                ),
                                fontSize:
                                    R.sp(
                                  context,
                                  21,
                                ),
                              ),
                              border:
                                  InputBorder.none,
                              enabledBorder:
                                  InputBorder.none,
                              focusedBorder:
                                  InputBorder.none,
                              disabledBorder:
                                  InputBorder.none,
                            ),
                          ),
                          if (hasImages)
                            _SelectedImagesPreview(
                              imagePaths:
                                  selectedImagePaths,
                              onRemove:
                                  removeImage,
                              removeEnabled:
                                  !isBusy,
                            ),
                          if (hasVideo)
                            _SelectedVideoPreview(
                              videoPath:
                                  selectedVideoPath!,
                              onRemove:
                                  removeVideo,
                              removeEnabled:
                                  !isBusy,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _CreateBottomBar(
              isBusy: isBusy,
              imageEnabled:
                  !hasVideo &&
                  selectedImagePaths.length <
                      4,
              videoEnabled:
                  !hasImages,
              selectedImagesCount:
                  selectedImagePaths.length,
              onPickImages:
                  pickImages,
              onPickVideo:
                  pickVideo,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedImagesPreview
    extends StatelessWidget {
  final List<String> imagePaths;

  final void Function(
    String path,
  ) onRemove;

  final bool removeEnabled;

  const _SelectedImagesPreview({
    required this.imagePaths,
    required this.onRemove,
    required this.removeEnabled,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final items =
        imagePaths.take(4).toList();

    return Padding(
      padding: EdgeInsets.only(
        top: R.size(context, 12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              items.length == 1 ? 1 : 2,
          crossAxisSpacing:
              R.size(context, 3),
          mainAxisSpacing:
              R.size(context, 3),
          childAspectRatio:
              items.length == 1
                  ? 16 / 10
                  : 1,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          final path = items[index];

          return _LocalImageItem(
            path: path,
            removeEnabled:
                removeEnabled,
            onRemove: () {
              onRemove(path);
            },
          );
        },
      ),
    );
  }
}

class _LocalImageItem
    extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  final bool removeEnabled;

  const _LocalImageItem({
    required this.path,
    required this.onRemove,
    required this.removeEnabled,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        R.size(context, 14),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return _LocalMediaError(
                colorScheme: colorScheme,
              );
            },
          ),
          _RemoveMediaButton(
            onTap: onRemove,
            enabled: removeEnabled,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    R.size(context, 14),
                  ),
                  border: Border.all(
                    color: colorScheme
                        .outlineVariant
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedVideoPreview
    extends StatelessWidget {
  final String videoPath;
  final VoidCallback onRemove;
  final bool removeEnabled;

  const _SelectedVideoPreview({
    required this.videoPath,
    required this.onRemove,
    required this.removeEnabled,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        top: R.size(context, 12),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          R.size(context, 16),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.black,
                alignment:
                    Alignment.center,
                child: Icon(
                  Icons.video_file_outlined,
                  color: Colors.white,
                  size:
                      R.size(context, 70),
                ),
              ),
              Center(
                child: Container(
                  width:
                      R.size(context, 58),
                  height:
                      R.size(context, 58),
                  decoration:
                      BoxDecoration(
                    color: Colors.black
                        .withValues(
                      alpha: 0.55,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .play_arrow_rounded,
                    color: Colors.white,
                    size:
                        R.size(
                      context,
                      42,
                    ),
                  ),
                ),
              ),
              _RemoveMediaButton(
                onTap: onRemove,
                enabled: removeEnabled,
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
                        R.size(
                      context,
                      8,
                    ),
                    vertical:
                        R.size(
                      context,
                      4,
                    ),
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.black
                        .withValues(
                      alpha: 0.68,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      R.size(
                        context,
                        8,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        R.size(
                          context,
                          16,
                        ),
                      ),
                      border: Border.all(
                        color: colorScheme
                            .outlineVariant
                            .withValues(
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

class _RemoveMediaButton
    extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;

  const _RemoveMediaButton({
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return PositionedDirectional(
      top: R.size(context, 8),
      end: R.size(context, 8),
      child: InkWell(
        onTap: enabled
            ? onTap
            : null,
        borderRadius:
            BorderRadius.circular(999),
        child: Container(
          width: R.size(context, 34),
          height: R.size(context, 34),
          decoration: BoxDecoration(
            color: Colors.black
                .withValues(
              alpha: enabled
                  ? 0.62
                  : 0.30,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: R.size(context, 22),
          ),
        ),
      ),
    );
  }
}

class _LocalMediaError
    extends StatelessWidget {
  final ColorScheme colorScheme;

  const _LocalMediaError({
    required this.colorScheme,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color: colorScheme
          .surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color:
            colorScheme.onSurfaceVariant,
        size: R.size(context, 32),
      ),
    );
  }
}

class _CreateBottomBar
    extends StatelessWidget {
  final bool isBusy;
  final bool imageEnabled;
  final bool videoEnabled;

  final int selectedImagesCount;

  final VoidCallback onPickImages;
  final VoidCallback onPickVideo;

  const _CreateBottomBar({
    required this.isBusy,
    required this.imageEnabled,
    required this.videoEnabled,
    required this.selectedImagesCount,
    required this.onPickImages,
    required this.onPickVideo,
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
        height:
            R.size(context, 58),
        padding:
            EdgeInsets.symmetric(
          horizontal:
              R.size(context, 14),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: colorScheme
                  .outlineVariant
                  .withValues(
                alpha: 0.45,
              ),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed:
                  !isBusy &&
                          imageEnabled
                      ? onPickImages
                      : null,
              icon: Icon(
                Icons.image_outlined,
                color: imageEnabled &&
                        !isBusy
                    ? const Color(
                        0xFF1D9BF0,
                      )
                    : colorScheme
                        .onSurfaceVariant
                        .withValues(
                      alpha: 0.35,
                    ),
                size:
                    R.size(context, 28),
              ),
            ),
            IconButton(
              onPressed:
                  !isBusy &&
                          videoEnabled
                      ? onPickVideo
                      : null,
              icon: Icon(
                Icons
                    .video_library_outlined,
                color: videoEnabled &&
                        !isBusy
                    ? const Color(
                        0xFF1D9BF0,
                      )
                    : colorScheme
                        .onSurfaceVariant
                        .withValues(
                      alpha: 0.35,
                    ),
                size:
                    R.size(context, 28),
              ),
            ),
            if (isBusy) ...[
              SizedBox(
                width:
                    R.size(context, 12),
              ),
              SizedBox(
                width:
                    R.size(context, 20),
                height:
                    R.size(context, 20),
                child:
                    const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ],
            const Spacer(),
            Text(
              '$selectedImagesCount/4',
              style: TextStyle(
                color: colorScheme
                    .onSurfaceVariant,
                fontSize:
                    R.sp(context, 12),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}