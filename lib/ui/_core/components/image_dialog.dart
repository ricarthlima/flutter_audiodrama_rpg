import 'package:flutter/material.dart';

import '../dimensions.dart';

Future<dynamic> showImageDialog({
  required BuildContext context,
  required String imageUrl,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          height: height(context),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    },
  );
}
