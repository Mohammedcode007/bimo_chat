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
    return imagePath.startsWith('http://') || imagePath.startsWith('https://');
  }

  void saveImage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image save is not connected yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildImage(BuildContext context) {
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
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
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

    final file = File(imagePath);

    return Image.file(
      file,
      fit: BoxFit.contain,
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
            child: Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: buildImage(context),
              ),
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