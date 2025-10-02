import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/guest/campaign_guest_screen.dart';
import 'package:provider/provider.dart';

import '../../_core/providers/user_provider.dart';
import '../../data/services/chat_service.dart';
import '../_core/components/movable_expandable_screen.dart';
import '../_core/dimensions.dart';
import '../_core/web/open_popup/open_popup.dart';
import '../sheet/providers/sheet_view_model.dart';
import '../sheet/sheet_screen.dart';
import 'campaign_router_screen.dart';
import 'components/campaign_drawer.dart';
import 'drawer/campaign_drawer_achievements.dart';
import 'drawer/campaign_drawer_chat.dart';
import 'drawer/campaign_drawer_turn_order.dart';
import 'partials/campaign_first_interact_screen.dart';
import 'drawer/campaign_drawer_sheets.dart';
import 'view/campaign_view_model.dart';
import 'widgets/campaign_people_connected.dart';
import 'widgets/group_notifications.dart';

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
      CampaignProvider campaignVM = Provider.of<CampaignProvider>(
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
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);

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
            : Center(child: Text("Campanha não encontrada.")),
      ),
    );
  }

  Widget _buildBodyWithDrawer(CampaignProvider campaignVM) {
    final sheetVM = context.read<SheetViewModel>();

    return Stack(
      children: [
        CampaignRouterScreen(),
        if (campaignVM.currentTab != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 48),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: IconButton.filled(
                        onPressed: () {
                          campaignVM.currentTab = null;
                        },
                        icon: Icon(Icons.close),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: min(
                      width(context),
                      campaignVM.currentTab!.index == 0 ? 500 : 400,
                    ),
                    padding: EdgeInsets.all(16),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: IndexedStack(
                      index: campaignVM.currentTab!.index,
                      children: [
                        CampaignDrawerChat(),
                        CampaignDrawerSheets(),
                        CampaignDrawerTurnOrder(),
                        CampaignDrawerAchievements(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        Align(alignment: Alignment.centerRight, child: CampaignDrawer()),
        GroupNotifications(),
        Stack(
          children: campaignVM.listOpenSheet.map((e) {
            return MovableExpandableScreen(
              key: ValueKey<String>(e.sheet.id),
              title: e.sheet.characterName,
              onPopup: () {
                openUrl("#/${e.appUser.username!}/sheet/${e.sheet.id}");
              },
              onExit: () => campaignVM..closeSheetInCampaign(e.sheet),
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => SheetViewModel(
                      id: e.sheet.id,
                      username: e.appUser.username!,
                      isWindowed: true,
                      actionRepo: sheetVM.actionRepo,
                      spellRepo: sheetVM.spellRepo,
                    ),
                  ),
                ],
                child: SheetScreen(
                  id: e.sheet.id,
                  username: e.appUser.username!,
                ),
              ),
            );
          }).toList(),
        ),
        Selector<CampaignProvider, String?>(
          selector: (context, cp) => cp.campaign?.id,
          builder: (context, value, child) {
            return Positioned(
              bottom: 8,
              left: 8,
              child: CampaignPeopleConnected(),
            );
          },
        ),
        if (campaignVM.isOwner && campaignVM.isPreviewVisible)
          MovableExpandableScreen(
            title: "Visualização",
            onExit: () {
              campaignVM.isPreviewVisible = false;
            },
            child: CampaignGuestScreen(),
          ),
      ],
    );
  }
}
