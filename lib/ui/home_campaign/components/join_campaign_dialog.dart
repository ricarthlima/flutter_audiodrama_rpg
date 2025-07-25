import 'package:flutter/material.dart';
import '../../_core/components/show_snackbar.dart';
import '../../_core/fonts.dart';

import '../../_core/app_colors.dart';
import '../../_core/widgets/circular_progress_indicator.dart';
import '../view/home_campaign_view_model.dart';

showJoinCampaignDialog({required BuildContext context}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(child: _JoinCampaignDialog());
    },
  );
}

class _JoinCampaignDialog extends StatefulWidget {
  const _JoinCampaignDialog();

  @override
  State<_JoinCampaignDialog> createState() => __JoinCampaignDialogState();
}

class __JoinCampaignDialogState extends State<_JoinCampaignDialog> {
  final TextEditingController _codeController = TextEditingController();
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
                "Ingressar em uma campanha",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _codeController,
                  maxLength: 9,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 48),
                  decoration: const InputDecoration(
                    label: Text("Código da campanha"),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Cadê o o código?";
                    }
                    if (value.length < 5) {
                      return "Os códigos possuem 9 caracteres.";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _onJoinPressed();
            },
            child: (isLoading)
                ? const CPIElevatedButton()
                : const Text("Ingressar!"),
          ),
        ],
      ),
    );
  }

  void _onJoinPressed() async {
    HomeCampaignInteract.joinCampaign(joinCode: _codeController.text).then(
      (value) {
        if (!mounted) return;
        Navigator.pop(context);
      },
    ).onError(
      (error, stackTrace) {
        if (!mounted) return;
        showSnackBar(context: context, message: "Código não encontrado.");
        Navigator.pop(context);
      },
    );
  }
}
