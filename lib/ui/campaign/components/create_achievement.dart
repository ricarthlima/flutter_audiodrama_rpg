import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../_core/app_colors.dart';
import '../../_core/utils/load_image.dart';
import '../../_core/widgets/circular_progress_indicator.dart';

showCreateAchievementDialog({required BuildContext context}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(child: _CreateAchievementDialog());
    },
  );
}

class _CreateAchievementDialog extends StatefulWidget {
  const _CreateAchievementDialog();

  @override
  State<_CreateAchievementDialog> createState() =>
      __CreateAchievementDialogState();
}

class __CreateAchievementDialogState extends State<_CreateAchievementDialog> {
  final formKey = GlobalKey<FormState>();

  XFile? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isHide = false;
  bool isHideDescription = true;
  bool isImageHided = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 4,
          color: AppColors.red,
        ),
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
              const Text(
                "Criar conquista",
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
                  (image != null)
                      ? SizedBox(
                          height: 300,
                          child: FutureBuilder(
                            future: image!.readAsBytes(),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                case ConnectionState.done:
                                  return Image.memory(snapshot.data!);
                              }
                            },
                          ),
                        )
                      : SizedBox(
                          height: 128,
                          width: 128,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _onUploadImagePressed();
                                },
                                icon: const Icon(Icons.upload),
                              ),
                              const Text(
                                "Opcionalmente,\ninsira um símbolo.\n(Quadrado, até 1 MB)",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
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
            child:
                (isLoading) ? const CPIElevatedButton() : const Text("Salvar!"),
          )
        ],
      ),
    );
  }

  void _onUploadImagePressed() async {
    onLoadImageClicked(context: context, maxSizeInBytes: 1000000)
        .then((imageBytes) {
      setState(() {
        image = imageBytes;
      });
    });
  }

  void _onCreatePressed() async {
    if (formKey.currentState!.validate()) {
      String name = nameController.text;
      String description = descController.text;

      await context.read<CampaignViewModel>().onCreateAchievement(
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
