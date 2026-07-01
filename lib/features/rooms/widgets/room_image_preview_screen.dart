// import 'dart:io';

// import 'package:flutter/material.dart';

// import '../../../core/utils/responsive.dart';

// class RoomImagePreviewScreen extends StatelessWidget {
//   final String imagePath;

//   const RoomImagePreviewScreen({
//     super.key,
//     required this.imagePath,
//   });

//   bool get isNetworkImage {
//     final value = imagePath.trim().toLowerCase();
//     return value.startsWith('http://') || value.startsWith('https://');
//   }

//   void saveImage(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Image save is not connected yet'),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Widget imageWidget() {
//     if (imagePath.trim().isEmpty) {
//       return const Icon(
//         Icons.broken_image_rounded,
//         color: Colors.white,
//         size: 54,
//       );
//     }

//     if (isNetworkImage) {
//       return Image.network(
//         imagePath.trim(),
//         fit: BoxFit.contain,
//         alignment: Alignment.center,
//         gaplessPlayback: true,
//         filterQuality: FilterQuality.high,
//         loadingBuilder: (context, child, progress) {
//           if (progress == null) return child;

//           return const Center(
//             child: CircularProgressIndicator(
//               color: Colors.white,
//               strokeWidth: 2,
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return const Icon(
//             Icons.broken_image_rounded,
//             color: Colors.white,
//             size: 54,
//           );
//         },
//       );
//     }

//     return Image.file(
//       File(imagePath),
//       fit: BoxFit.contain,
//       alignment: Alignment.center,
//       gaplessPlayback: true,
//       filterQuality: FilterQuality.high,
//       errorBuilder: (context, error, stackTrace) {
//         return const Icon(
//           Icons.broken_image_rounded,
//           color: Colors.white,
//           size: 54,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final screenWidth = constraints.maxWidth;
//                 final screenHeight = constraints.maxHeight;

//                 return InteractiveViewer(
//                   minScale: 1,
//                   maxScale: 5,
//                   panEnabled: true,
//                   scaleEnabled: true,
//                   clipBehavior: Clip.none,
//                   boundaryMargin: EdgeInsets.all(R.size(context, 100)),
//                   child: SizedBox(
//                     width: screenWidth,
//                     height: screenHeight,
//                     child: Center(
//                       child: FittedBox(
//                         fit: BoxFit.contain,
//                         alignment: Alignment.center,
//                         child: SizedBox(
//                           width: screenWidth,
//                           height: screenHeight,
//                           child: Center(
//                             child: imageWidget(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           SafeArea(
//             child: Padding(
//               padding: EdgeInsets.all(R.size(context, 12)),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.close_rounded,
//                       color: Colors.white,
//                       size: 34,
//                     ),
//                   ),

//                   const Spacer(),

//                   IconButton(
//                     onPressed: () => saveImage(context),
//                     icon: const Icon(
//                       Icons.download_rounded,
//                       color: Colors.white,
//                       size: 34,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  Future<Uint8List> _downloadImageBytes(String url) async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      final bytes = await response.fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );

      return Uint8List.fromList(bytes);
    } finally {
      client.close(force: true);
    }
  }

  String _extensionFromBytes(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'jpg';
    }

    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }

    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'gif';
    }

    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }

    return 'png';
  }

  Future<File> _createSavableImageFile() async {
    final path = imagePath.trim();

    if (path.isEmpty) {
      throw Exception('Image path is empty');
    }

    Uint8List bytes;

    if (isNetworkImage) {
      bytes = await _downloadImageBytes(path);
    } else {
      final file = File(path);

      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      bytes = await file.readAsBytes();
    }

    if (bytes.isEmpty) {
      throw Exception('Image bytes are empty');
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final ext = _extensionFromBytes(bytes);

    if (ext == 'jpg' || ext == 'png') {
      final outputFile = File('${tempDir.path}/Plus_image_$timestamp.$ext');
      await outputFile.writeAsBytes(bytes, flush: true);
      return outputFile;
    }

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Unsupported image format');
    }

    final pngBytes = img.encodePng(decoded);
    final outputFile = File('${tempDir.path}/Plus_image_$timestamp.png');

    await outputFile.writeAsBytes(pngBytes, flush: true);

    return outputFile;
  }

  Future<void> saveImage(BuildContext context) async {
    try {
      final file = await _createSavableImageFile();

      await Gal.putImage(
        file.path,
        album: 'Plus Chat',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved to gallery'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on GalException catch (error) {
      debugPrint('[SAVE_IMAGE_GAL_ERROR] $error');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${error.type}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      debugPrint('[SAVE_IMAGE_ERROR] $error');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image save failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget buildImage({
    required double width,
    required double height,
  }) {
    final path = imagePath.trim();

    if (path.isEmpty) {
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
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
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
      File(path),
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
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
                  clipBehavior: Clip.none,
                  boundaryMargin: EdgeInsets.all(
                    R.size(context, 200),
                  ),
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Center(
                      child: buildImage(
                        width: screenWidth,
                        height: screenHeight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(
                  R.size(context, 12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () => saveImage(context),
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}