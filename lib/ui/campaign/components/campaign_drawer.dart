import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/audio_provider.dart';
import '../../../data/services/chat_service.dart';
import '../../../router.dart';
import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../_core/widgets/compactable_button.dart';
import '../../home/utils/home_tabs.dart';
import '../../settings/settings_screen.dart';
import '../utils/campaign_subpages.dart';
import '../view/campaign_view_model.dart';
import '../dialogs/campaign_settings_dialog.dart';

class CampaignDrawer extends StatelessWidget {
  const CampaignDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignVM = Provider.of<CampaignProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return MouseRegion(
      // onEnter: (event) {
      //   if (event.delta.dx > 0) {
      //     campaignVM.isDrawerClosed = false;
      //   }
      // },
      onExit: (_) => campaignVM.isDrawerClosed = true,
      child: AnimatedContainer(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(
          (campaignVM.isDrawerClosed && campaignVM.currentTab == null)
              ? 25
              : 250,
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
                if (!campaignVM.isDrawerClosed)
                  InkWell(
                    onTap: () {
                      campaignVM.isDrawerClosed = true;
                    },
                    child: Container(
                      color: AppColors.red,
                      child: Center(
                        child: Text(
                          "FECHAR",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: "BUNGEE",
                          ),
                        ),
                      ),
                    ),
                  ),
                if (campaignVM.isDrawerClosed)
                  IconButton(
                    onPressed: () {
                      campaignVM.isDrawerClosed = false;
                    },
                    tooltip: "Expandir",
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.menu, color: Colors.white),
                  ),
                if (!campaignVM.isDrawerClosed)
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
                                  text: campaignVM.campaign!.enterCode,
                                ),
                              );
                            },
                            tooltip: "Copiar",
                            icon: Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ],
                  ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: false,
                  ),
                  title: "Sobre ${campaignVM.campaign!.name}",
                  leadingIcon: Icons.local_florist_outlined,
                  onPressed: () {
                    showCampaignSettingsDialog(context: context);
                  },
                ),
                Divider(thickness: 0.25),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: campaignVM.currentTab == CampaignTabs.chat,
                  ),
                  title: "Chat",
                  leading: StreamBuilder(
                    stream: ChatService.instance.listenChat(
                      campaignId: campaignVM.campaign!.id,
                    ),
                    builder: (context, snapshot) {
                      int count = 0;

                      if (snapshot.data != null &&
                          campaignVM.currentTab != CampaignTabs.chat) {
                        if (campaignVM.isChatFirstTime) {
                          campaignVM.countChatMessages = snapshot.data!.size;
                          campaignVM.isChatFirstTime = false;
                        } else {
                          count =
                              snapshot.data!.size -
                              campaignVM.countChatMessages;
                        }
                      }

                      if (count > 0) {
                        audioProvider.playChatNotification();
                      }

                      return Badge.count(
                        count: count,
                        isLabelVisible: count > 0,
                        textColor: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color!,
                        backgroundColor: AppColors.red,
                        child: Icon(Icons.chat),
                      );
                    },
                  ),
                  onPressed: () {
                    campaignVM.currentTab = CampaignTabs.chat;
                    campaignVM.isDrawerClosed = true;
                    campaignVM.isChatFirstTime = true;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Divider(thickness: 0.25),
                if (kIsWeb)
                  CompactableButton(
                    controller: CompactableButtonController(
                      isCompressed: campaignVM.isDrawerClosed,
                      isSelected: false,
                    ),
                    title: (!FullScreen.isFullScreen)
                        ? "Tela cheia"
                        : "Sair de tela cheia",
                    leadingIcon: (!FullScreen.isFullScreen)
                        ? Icons.fullscreen
                        : Icons.fullscreen_exit,
                    onPressed: () {
                      FullScreen.setFullScreen(!FullScreen.isFullScreen);
                    },
                  ),
                CompactableButton(
                  controller: CompactableButtonController(
                    isCompressed: campaignVM.isDrawerClosed,
                    isSelected: false,
                  ),
                  title: "Configurações gerais",
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
                      subPage: HomeTabs.campaigns,
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
