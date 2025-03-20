import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/exceptions/general_exceptions.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> onLoadImageClicked({
  required BuildContext context,
  int maxSizeInBytes = 2000000,
}) async {
  ImagePicker picker = ImagePicker();

  XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    requestFullMetadata: false,
  );

  if (image != null) {
    int sizeInBytes = await image.length();

    if (sizeInBytes >= maxSizeInBytes) {
      throw ImageTooLargeException();
    } else {
      return image;
    }
  }

  return null;
}
