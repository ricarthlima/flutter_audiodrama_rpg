import 'package:flutter/material.dart';

Future<void> showCampaignSettingsDialog({required BuildContext context}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(child: _CampaignSettingsDialog()),
  );
}

class _CampaignSettingsDialog extends StatefulWidget {
  const _CampaignSettingsDialog();

  @override
  State<_CampaignSettingsDialog> createState() =>
      __CampaignSettingsDialogState();
}

class __CampaignSettingsDialogState extends State<_CampaignSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return;
  }
}
