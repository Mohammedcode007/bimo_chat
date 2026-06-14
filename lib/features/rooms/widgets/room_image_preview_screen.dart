import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class RoomImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const RoomImagePreviewScreen({
    super.key,
    required this.imagePath,
  });

  bool get isNetworkImage {
    final value = imagePath.trim().toLowerCase();

    return value.startsWith('http://') || value.startsWith('https://');
  }

  void saveImage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image save is not connected yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildImage({
    required double width,
    required double height,
  }) {
    if (imagePath.trim().isEmpty) {
      return const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.white,
          size: 54,
        ),
      );
    }

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.white,
              size: 54,
            ),
          );
        },
      );
    }

    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white,
            size: 54,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: buildImage(
                      width: screenWidth,
                      height: screenHeight,
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(R.size(context, 12)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () => saveImage(context),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}