import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/remove_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/providers/sheet_view_model.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/list_action.dart';
import '../../_core/fonts.dart';
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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: 500,
      height: 700,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          body: Stack(
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
                padding: EdgeInsets.only(
                  top: (campaignVM.isOwner) ? 64 : 16,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: TabBarView(
                        children: [
                          _buildGeneralTab(campaignVM),
                          _buildWorksTab(campaignVM, sheetVM),
                          Text("Módulos"),
                          _buildDangerTab(campaignVM),
                        ],
                      ),
                    ),
                    if (!campaignVM.isOwner)
                      ElevatedButton.icon(
                        onPressed: () {
                          showRemoveDialog(
                            context: context,
                            message: "Tem certeza que deseja sair da campanha?",
                            labelConfirmationButton: "SAIR",
                          ).then((value) {
                            campaignVM.exitCampaign();
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.red,
                          ),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        icon: Icon(Icons.logout),
                        label: Text("Sair da campanha"),
                      ),
                    if (campaignVM.isOwner)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          campaignVM.onSave().then((value) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          });
                        },
                        child: (isLoading)
                            ? CircularProgressIndicator.adaptive()
                            : Text("Salvar"),
                      ),
                  ],
                ),
              ),

              if (campaignVM.isOwner)
                Align(
                  alignment: Alignment.topCenter,
                  child: TabBar(
                    tabs: [
                      Tab(child: Text("Geral")),
                      Tab(child: Text("Ofícios")),
                      Tab(child: Text("Módulos")),
                      Tab(child: Text("Área de Perigo")),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  NamedWidget _getNameWidget(CampaignViewModel campaignVM) {
    return NamedWidget(
      title: "Nome",
      isLeft: true,
      child: SizedBox(
        width: 500 - 32,
        child: (campaignVM.isOwner)
            ? TextField(
                controller: campaignVM.nameController,
                style: TextStyle(
                  fontSize: isVertical(context) ? 18 : 24,
                  fontFamily: FontFamily.sourceSerif4,
                ),
                maxLength: 40,
              )
            : Text(
                campaignVM.campaign!.name ?? "(Sem nome)",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isVertical(context) ? 18 : 32,
                  fontFamily: FontFamily.bungee,
                  color: AppColors.red,
                ),
              ),
      ),
    );
  }

  Widget _getDescriptionWidget(CampaignViewModel campaignVM) {
    return NamedWidget(
      title: "Descrição",
      isLeft: true,
      child: (campaignVM.isOwner)
          ? SizedBox(
              width: 500 - 32,
              child: TextField(
                controller: campaignVM.descController,
                maxLength: 5000,
                maxLines: null,
              ),
            )
          : Text(campaignVM.campaign!.description ?? "..."),
    );
  }

  void _onUploadImagePressed(CampaignViewModel campaignVM) async {
    XFile? image = await onLoadImageClicked(context: context);

    if (image != null) {
      campaignVM.onUpdateImage(image);
    }
  }

  Widget _buildGeneralTab(CampaignViewModel campaignVM) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: campaignVM.campaign!.enterCode),
                    );
                  },
                  tooltip: "Copiar",
                  icon: Icon(Icons.copy),
                ),
              ],
            ),
          ],
        ),
        _getNameWidget(campaignVM),
        _getDescriptionWidget(campaignVM),
        if (campaignVM.isOwner) _getChangeImageWidget(campaignVM),
      ],
    );
  }

  Widget _getChangeImageWidget(CampaignViewModel campaignVM) {
    return NamedWidget(
      title: "Mudar imagem de fundo",
      isLeft: true,
      child: Column(
        spacing: 8,
        children: [
          if (campaignVM.campaign!.imageBannerUrl != null)
            SizedBox(
              width: 500 - 32,
              child: Image.network(campaignVM.campaign!.imageBannerUrl!),
            ),
          Row(
            spacing: 32,
            children: [
              ElevatedButton.icon(
                onPressed: () => _onUploadImagePressed(campaignVM),
                label: Text("Alterar imagem"),
                icon: Icon(Icons.image_outlined),
              ),
              if (campaignVM.campaign!.imageBannerUrl != null)
                ElevatedButton.icon(
                  onPressed: () => campaignVM.onRemoveImage(),
                  label: Text("Remover imagem"),
                  icon: Icon(Icons.remove, color: AppColors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorksTab(CampaignViewModel campaignVM, SheetViewModel sheetVM) {
    return Column(
      spacing: 8,
      children: [
        Opacity(
          opacity: 0.5,
          child: Text(
            "Ative ou desative ofícios para essa campanha. Ofícios desativados estarão indisponíveis para as pessoas jogadoras.",
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sheetVM.actionRepo.getListWorks().length,
            itemBuilder: (context, index) {
              ListAction work = sheetVM.actionRepo.getListWorks()[index];
              return CheckboxListTile(
                value: campaignVM
                    .campaign!
                    .campaignSheetSettings
                    .listActiveWorkIds
                    .contains(work.name),
                title: Text(
                  work.name[0].toUpperCase() + work.name.substring(1),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  campaignVM.toggleActiveWork(work.name);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDangerTab(CampaignViewModel campaignVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NamedWidget(
          title: "Excluir campanha definitivamente",
          isLeft: true,
          child: ElevatedButton.icon(
            onPressed: () {
              showRemoveDialog(
                context: context,
                message: "Deseja remover '${campaignVM.campaign!.name}'?",
              ).then((result) {
                if (result != null && result) {
                  setState(() {
                    isLoading = true;
                  });
                  campaignVM.deleteCampaign().then((value) {
                    if (!mounted) return;
                    context.go("/campaigns");
                  });
                }
              });
            },
            icon: Icon(Icons.delete),
            label: isLoading
                ? CircularProgressIndicator()
                : Text("Remover campanha"),
          ),
        ),
      ],
    );
  }
}
