import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/chat_service.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/movable_expandable_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/open_popup.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/campaign_drawer.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/partials/achievements_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/partials/campaign_first_interact_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/partials/campaign_home_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/partials/sheets_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/group_notifications.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/sheet_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:provider/provider.dart';

import 'partials/chat_widget.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(
        context,
        listen: false,
      );
      campaignVM.isChatFirstTime = true;

      Provider.of<UserProvider>(context, listen: false).onInitialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    ChatService.instance.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    // TODO: modularizar esse campanha nao encontrada
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 1250),
        child: (!campaignVM.hasInteracted)
            ? CampaignFirstInteractScreen()
            : (campaignVM.isLoading)
                ? Center(child: CircularProgressIndicator())
                : (campaignVM.campaign != null && campaignVM.isOwnerOrInvited)
                    ? _buildBodyWithDrawer(campaignVM)
                    : Center(
                        child: Text("Campanha não encontrada."),
                      ),
      ),
    );
  }

  Widget _buildBodyWithDrawer(CampaignViewModel campaignVM) {
    return Stack(
      children: [
        CampaignHomeScreen(),
        if (campaignVM.currentTab != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 48),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: IconButton.filled(
                        onPressed: () {
                          campaignVM.currentTab = null;
                        },
                        iconSize: 16,
                        icon: Icon(Icons.close),
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    padding: EdgeInsets.all(16),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: IndexedStack(
                      index: campaignVM.currentTab!.index,
                      children: [
                        CampaignChatWidget(),
                        CampaignSheetsWidget(),
                        CampaignAchievementsWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: CampaignDrawer(),
        ),
        GroupNotifications(),
        Stack(
          children: campaignVM.listOpenSheet.map(
            (e) {
              return MovableExpandableScreen(
                title: e.sheet.characterName,
                onPopup: () {
                  openUrl("#/${e.appUser.username!}/sheet/${e.sheet.id}");
                },
                onExit: () => campaignVM.closeSheetInCampaign(e.sheet),
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => SheetViewModel(
                        id: e.sheet.id,
                        username: e.appUser.username!,
                        isWindowed: true,
                        actionRepo: context.read<SheetViewModel>().actionRepo,
                        conditionRepo:
                            context.read<SheetViewModel>().conditionRepo,
                      ),
                    ),
                  ],
                  child: SheetScreen(),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
