import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class RoomImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const RoomImagePreviewScreen({super.key, required this.imagePath});

  void saveImage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: InteractiveViewer(child: Image.file(file))),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(R.size(context, 12)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
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
