import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/exceptions/general_exceptions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/image_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/snackbars/snackbars.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/utils/load_image.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/providers/sheet_view_model.dart';
import 'package:provider/provider.dart';

class SettingTokenItem extends StatelessWidget {
  final int index;
  const SettingTokenItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);
    return InkWell(
      onTap: index < sheetVM.sheet!.listTokens.length
          ? () {
              sheetVM.setTokenIndex(index);
            }
          : null,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
            width: 4,
            color: sheetVM.sheet!.indexToken == index
                ? AppColors.red
                : sheetVM.sheet!.listTokens.length <= index
                ? Colors.blueGrey
                : Colors.grey,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            children: [
              Center(
                child: (index < sheetVM.sheet!.listTokens.length)
                    ? Image.network(sheetVM.sheet!.listTokens[index])
                    : Placeholder(),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.black.withAlpha(100),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  child: SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Token ${index + 1} ${sheetVM.sheet!.listTokens.length <= index ? '(Não definido)' : ''}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            if (sheetVM.sheet!.listTokens.length >= index)
                              InkWell(
                                onTap: () {
                                  _uploadImage(context, sheetVM);
                                },
                                child: Icon(Icons.file_upload_outlined),
                              ),
                            if (sheetVM.sheet!.listTokens.length > index)
                              InkWell(
                                onTap: () {
                                  showImageDialog(
                                    context: context,
                                    imageUrl: sheetVM.sheet!.listTokens[index],
                                  );
                                },
                                child: Icon(Icons.fullscreen),
                              ),
                            if (sheetVM.sheet!.listTokens.length - 1 == index)
                              InkWell(
                                onTap: () {
                                  sheetVM.removeToken(index);
                                },
                                child: Icon(Icons.delete, color: AppColors.red),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadImage(BuildContext context, SheetViewModel sheetVM) async {
    try {
      Uint8List? image = await loadAndCompressImage(context);
      if (image != null) {
        sheetVM.uploadToken(image: image, index: index);
      }
    } on ImageTooLargeException {
      if (!context.mounted) return;
      showImageTooLargeSnackbar(context);
    }
  }
}
