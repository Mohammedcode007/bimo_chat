import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageAsBase64({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    if (file == null) return null;

    final bytes = await file.readAsBytes();

    final mimeType =
        lookupMimeType(file.path, headerBytes: bytes) ?? 'image/jpeg';

    final base64File = base64Encode(bytes);

    return 'data:$mimeType;base64,$base64File';
  }
}