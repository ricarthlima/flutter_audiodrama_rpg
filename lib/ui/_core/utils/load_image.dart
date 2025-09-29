import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/exceptions/general_exceptions.dart';

/// Pode lançar [ImageTooLargeException] se a imagem for grande demais.
Future<Uint8List?> loadAndCompressImage(
  BuildContext context, {
  int maxSizeInBytes = 500000,
  int quality = 30,
  int? minWidth,
  int? minHeight,
}) async {
  ImagePicker picker = ImagePicker();

  XFile? imageFile = await picker.pickImage(
    source: ImageSource.gallery,
    requestFullMetadata: true,
  );

  if (imageFile != null) {
    int sizeInBytes = await imageFile.length();

    if (sizeInBytes >= maxSizeInBytes) {
      throw ImageTooLargeException();
    } else {
      Uint8List imageBytes = await imageFile.readAsBytes();
      Uint8List imageCompressed = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        format: CompressFormat.webp,
        minWidth: minWidth ?? 1920,
        minHeight: minHeight ?? 1080,
      );
      return imageCompressed;
    }
  }

  return null;
}

class ImageLoaded {
  String name;
  String extension;
  Uint8List bytes;

  ImageLoaded({
    required this.name,
    required this.extension,
    required this.bytes,
  });
}
