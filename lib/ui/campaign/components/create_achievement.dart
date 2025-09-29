import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/exceptions/general_exceptions.dart';
import '../../../domain/models/campaign_achievement.dart';
import '../../_core/app_colors.dart';
import '../../_core/snackbars/snackbars.dart';
import '../../_core/utils/load_image.dart';
import '../../_core/widgets/circular_progress_indicator.dart';
import '../view/campaign_view_model.dart';

Future showCreateEditAchievementDialog({
  required BuildContext context,
  CampaignAchievement? achievement,
}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(child: _CreateAchievementDialog(achievement: achievement));
    },
  );
}

class _CreateAchievementDialog extends StatefulWidget {
  final CampaignAchievement? achievement;
  const _CreateAchievementDialog({this.achievement});

  @override
  State<_CreateAchievementDialog> createState() =>
      __CreateAchievementDialogState();
}

class __CreateAchievementDialogState extends State<_CreateAchievementDialog> {
  final formKey = GlobalKey<FormState>();

  Uint8List? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isHide = false;
  bool isHideDescription = true;
  bool isImageHided = false;

  bool isLoading = false;

  @override
  void initState() {
    if (widget.achievement != null) {
      nameController.text = widget.achievement!.title;
      descController.text = widget.achievement!.description;
      isHide = widget.achievement!.isHided;
      isHideDescription = widget.achievement!.isDescriptionHided;
      isImageHided = widget.achievement!.isImageHided;
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: AppColors.red),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.all(16),
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (widget.achievement == null)
                    ? "Criar conquista"
                    : "Editar conquista",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(
            width: 300,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  (widget.achievement != null &&
                              widget.achievement!.imageUrl != null ||
                          image != null)
                      ? SizedBox(
                          height: 300,
                          child: Stack(
                            children: [
                              if (widget.achievement != null &&
                                  widget.achievement!.imageUrl != null &&
                                  image == null)
                                SizedBox(
                                  height: 300,
                                  child: Image.network(
                                    widget.achievement!.imageUrl!,
                                  ),
                                ),
                              if (image != null) Image.memory(image!),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 24.0,
                                    right: 8,
                                  ),
                                  child: IconButton.filled(
                                    onPressed: () {
                                      _onUploadImagePressed();
                                    },
                                    icon: const Icon(Icons.upload),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            IconButton(
                              onPressed: () {
                                _onUploadImagePressed();
                              },
                              icon: const Icon(Icons.upload),
                            ),
                            Text(
                              "Opcionalmente,\nadicione um ícone.",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                  const Text(
                    "(Proporção quadrada, até 1 MB)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nameController,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      label: Text("Nome da conquista"),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "O nome da campanha é obrigatório.";
                      }
                      if (value.length < 5) {
                        return "O nome da campanha deve ter pelo menos 5 caracteres.";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descController,
                    maxLength: 200,
                    maxLines: null,
                    decoration: const InputDecoration(
                      label: Text("Breve descrição"),
                    ),
                  ),
                  CheckboxListTile(
                    title: Text("Esconder imagem"),
                    value: isImageHided,
                    enabled: !isHide,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        isImageHided = !isImageHided;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Esconder descrição"),
                    value: isHideDescription,
                    enabled: !isHide,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        isHideDescription = !isHideDescription;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Conquista oculta"),
                    value: isHide,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        isHide = !isHide;
                        if (isHide) {
                          isImageHided = true;
                          isHideDescription = true;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _onCreatePressed();
            },
            child: (isLoading)
                ? const CPIElevatedButton()
                : const Text("Salvar!"),
          ),
        ],
      ),
    );
  }

  void _onUploadImagePressed() async {
    try {
      Uint8List? imageBytes = await loadAndCompressImage(
        context,
        minHeight: 64,
        minWidth: 64,
      );
      if (imageBytes != null) {
        setState(() {
          image = imageBytes;
        });
      }
    } on ImageTooLargeException {
      if (!mounted) return;
      showImageTooLargeSnackbar(context);
    }
  }

  void _onCreatePressed() async {
    if (formKey.currentState!.validate()) {
      String name = nameController.text;
      String description = descController.text;

      await context.read<CampaignProvider>().onCreateAchievement(
        idd: (widget.achievement != null) ? widget.achievement!.id : null,
        name: name,
        description: description,
        isHide: isHide,
        isHideDescription: isHideDescription,
        image: image,
        isImageHided: isImageHided,
      );

      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
