import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/open_popup.dart';

Future<dynamic> showImageDialog({
  required BuildContext context,
  required String imageUrl,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 4, color: Colors.white),
          ),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 8,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: height(context),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          if (kIsWeb) {
                            openUrl(imageUrl);
                          }
                          //TODO: Fazer para aplicativos
                        },
                        iconSize: 32,
                        icon: Icon(Icons.download),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconSize: 32,
                        icon: Icon(Icons.close),
                      ),
                    ],
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

class IconViewImageButton extends StatelessWidget {
  final double size;
  final String imageUrl;
  final Alignment alignment;
  const IconViewImageButton({
    super.key,
    this.size = 12,
    this.alignment = Alignment.topRight,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            showImageDialog(context: context, imageUrl: imageUrl);
          },
          child: Icon(
            Icons.visibility,
            size: size,
          ),
        ),
      ),
    );
  }
}
