import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

import '../../../router.dart';
import '../../_core/dimensions.dart';
import '../../_core/widgets/compactable_button.dart';
import '../../home/view/home_view_model.dart';
import '../../settings/settings_screen.dart';

class CampaignDrawer extends StatelessWidget {
  const CampaignDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignVM = Provider.of<CampaignViewModel>(context);

    return MouseRegion(
      onEnter: (event) {
        if (event.delta.dx > 0) {
          campaignVM.isDrawerClosed = false;
        }
      },
      onExit: (_) => campaignVM.isDrawerClosed = true,
      child: AnimatedContainer(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(
              (campaignVM.isDrawerClosed) ? 0 : 250,
            ),
        duration: Duration(milliseconds: 350),
        curve: Curves.ease,
        width: (campaignVM.isDrawerClosed) ? 48 : 275,
        height: height(context),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 8,
              children: [
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: campaignVM.currentTab == CampaignTabs.chat,
                  ),
                  title: "Chat",
                  leadingIcon: Icons.chat,
                  onPressed: () {
                    campaignVM.currentTab = CampaignTabs.chat;
                    campaignVM.isDrawerClosed = true;
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: campaignVM.currentTab == CampaignTabs.sheets,
                  ),
                  title: "Personagens",
                  leadingIcon: Icons.list_alt_sharp,
                  onPressed: () {
                    campaignVM.currentTab = CampaignTabs.sheets;
                    campaignVM.isDrawerClosed = true;
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected:
                        campaignVM.currentTab == CampaignTabs.achievements,
                  ),
                  title: "Conquistas",
                  leadingIcon: Icons.star,
                  onPressed: () {
                    campaignVM.currentTab = CampaignTabs.achievements;
                    campaignVM.isDrawerClosed = true;
                  },
                ),
              ],
            ),
            //TODO: RollLog
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                if (campaignVM.isOwner && !campaignVM.isDrawerClosed)
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
                    ],
                  ),
                Divider(thickness: 0.1),
                if (campaignVM.isOwner)
                  CompactableButton(
                    controller: CompactableButtonController(
                      isCompressed: campaignVM.isDrawerClosed,
                      isSelected: campaignVM.isEditing,
                    ),
                    title: campaignVM.isEditing
                        ? "Desativar edição"
                        : "Ativar edição",
                    leadingIcon: Icons.edit,
                    onPressed: () {
                      campaignVM.isEditing = !campaignVM.isEditing;
                    },
                  ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: false,
                  ),
                  title: "Configurações",
                  leadingIcon: Icons.settings,
                  onPressed: () {
                    showSettingsDialog(context);
                  },
                ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: false,
                  ),
                  title: "Voltar para tela inicial",
                  leadingIcon: Icons.home,
                  onPressed: () {
                    AppRouter().goHome(
                      context: context,
                      subPage: HomeSubPages.campaigns,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
