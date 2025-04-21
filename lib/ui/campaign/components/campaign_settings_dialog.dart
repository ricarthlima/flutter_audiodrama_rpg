import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart' show isVertical, width;
import '../../_core/utils/load_image.dart';
import '../../_core/widgets/named_widget.dart';
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
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: 600,
      height: 600,
      child: Stack(
        children: [
          if (campaignVM.campaign!.imageBannerUrl != null)
            Align(
              alignment: Alignment.topCenter,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(175),
                      Colors.transparent,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  campaignVM.campaign!.imageBannerUrl!,
                  height: (isVertical(context)) ? 250 : 300,
                  width: width(context),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getNameWidget(campaignVM),
                    _getDescriptionWidget(campaignVM),
                  ],
                ),
                Column(
                  spacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Código de entrada",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              campaignVM.campaign!.enterCode,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FontFamily.bungee,
                                fontSize: 24,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                      text: campaignVM.campaign!.enterCode),
                                );
                              },
                              tooltip: "Copiar",
                              icon: Icon(Icons.copy),
                            ),
                          ],
                        ),
                        Divider(thickness: 0.25),
                      ],
                    ),
                    if (campaignVM.isOwner)
                      Row(
                        spacing: 8,
                        children: [
                          Text("Imagem de fundo:"),
                          SizedBox(),
                          ElevatedButton.icon(
                            onPressed: () => _onUploadImagePressed(campaignVM),
                            label: Text("Alterar imagem"),
                            icon: Icon(Icons.image_outlined),
                          ),
                          if (campaignVM.campaign!.imageBannerUrl != null)
                            ElevatedButton.icon(
                              onPressed: () => campaignVM.onRemoveImage(),
                              label: Text("Remover imagem"),
                              icon: Icon(
                                Icons.remove,
                                color: AppColors.red,
                              ),
                            ),
                        ],
                      )
                  ],
                ),
              ],
            ),
          ),
          if (campaignVM.isOwner)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  thumbIcon: WidgetStatePropertyAll(Icon(Icons.edit)),
                  value: campaignVM.isEditing,
                  onChanged: (value) {
                    campaignVM.isEditing = !campaignVM.isEditing;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  NamedWidget _getNameWidget(CampaignViewModel campaignVM) {
    return NamedWidget(
      title: "Nome",
      isLeft: true,
      child: AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: (campaignVM.isEditing)
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width(context) * 0.8,
                  minWidth: width(context) * 0.2,
                ),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: campaignVM.nameController,
                    style: TextStyle(
                      fontSize: isVertical(context) ? 18 : 48,
                      fontFamily: FontFamily.sourceSerif4,
                    ),
                    maxLength: 40,
                  ),
                ),
              )
            : Text(
                campaignVM.campaign!.name ?? "Vamos adicionar um nome?",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isVertical(context) ? 18 : 48,
                  fontFamily: FontFamily.bungee,
                  color: AppColors.red,
                ),
              ),
      ),
    );
  }

  Widget _getDescriptionWidget(CampaignViewModel campaignVM) {
    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: (campaignVM.isEditing)
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width(context) * 0.8,
                minWidth: width(context) * 0.5,
              ),
              child: IntrinsicWidth(
                child: TextField(
                  controller: campaignVM.descController,
                  maxLength: 5000,
                  maxLines: null,
                ),
              ),
            )
          : Text(
              campaignVM.campaign!.description ?? "...",
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
