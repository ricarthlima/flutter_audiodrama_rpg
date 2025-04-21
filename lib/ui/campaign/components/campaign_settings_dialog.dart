import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../_core/utils/load_image.dart';
import '../view/campaign_view_model.dart';

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
    return Container(
      width: 600,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [Text()],
      ),
    );
  }

  void _onUploadImagePressed(CampaignViewModel campaignVM) async {
    XFile? image = await onLoadImageClicked(context: context);

    if (image != null) {
      campaignVM.onUpdateImage(image);
    }
  }
}
