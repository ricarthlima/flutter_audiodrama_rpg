import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../_core/app_colors.dart';
import '../../_core/utils/load_image.dart';
import '../../_core/widgets/circular_progress_indicator.dart';
import '../view/home_campaign_view_model.dart';

Future showCreateCampaignDialog({required BuildContext context}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(child: _CreateCampaignDialog());
    },
  );
}

class _CreateCampaignDialog extends StatefulWidget {
  const _CreateCampaignDialog();

  @override
  State<_CreateCampaignDialog> createState() => __CreateCampaignDialogState();
}

class __CreateCampaignDialogState extends State<_CreateCampaignDialog> {
  final formKey = GlobalKey<FormState>();

  XFile? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: AppColors.red),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.all(16),
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Criar nova campanha",
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
            width: 350,
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
                          height: 100,
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
                              const Text("Insira um banner. (1920x540)"),
                            ],
                          ),
                        ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nameController,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      label: Text("Nome da campanha"),
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
                : const Text("Crie um novo mundo!"),
          ),
        ],
      ),
    );
  }

  void _onUploadImagePressed() async {
    XFile? imageFile = await onLoadImageClicked(context: context);
    if (imageFile != null) {
      image = imageFile;
    }
    setState(() {});
  }

  void _onCreatePressed() async {
    String name = nameController.text;
    String desc = descController.text;

    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await HomeCampaignInteract.createCampaign(
        context: context,
        name: name,
        description: desc,
        fileImage: image,
      );

      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
