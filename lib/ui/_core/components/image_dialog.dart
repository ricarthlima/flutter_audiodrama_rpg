import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/open_popup.dart';

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
          width: height(context),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: height(context),
                width: height(context),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    onPressed: () {
                      if (kIsWeb) {
                        openUrl(imageUrl);
                      }
                      //TODO: Fazer para aplicativos
                    },
                    iconSize: 48,
                    icon: Icon(Icons.download),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
