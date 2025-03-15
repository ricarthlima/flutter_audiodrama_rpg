import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/settings/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../../router.dart';
import '../../_core/dimensions.dart';

import 'package:badges/badges.dart' as badges;

import '../view/campaign_view_model.dart';

AppBar getCampaignAppBar(BuildContext context) {
  CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

  if (campaignVM.isLoading ||
      !campaignVM.isOwnerOrInvited ||
      campaignVM.campaign == null) {
    return AppBar(
      toolbarHeight: 64,
      actions: [Container()],
    );
  }

  return AppBar(
    toolbarHeight: 64,
    leading: IconButton(
      onPressed: () {
        AppRouter().goHome(context: context, subPage: HomeSubPages.campaigns);
      },
      icon: Icon(Icons.arrow_back),
    ),
    backgroundColor: campaignVM.campaign!.imageBannerUrl != null
        ? Theme.of(context).scaffoldBackgroundColor.withAlpha(75)
        : null,
    actions: [
      if (campaignVM.isOwner)
        Row(
          children: [
            // Visibility(
            //   visible: !isVertical(context),
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Text("•"),
            //   ),
            // ),
            Visibility(
              visible: campaignVM.isEditing,
              child: Text("Saia da edição para salvar"),
            ),
            Visibility(
              visible: campaignVM.isEditing,
              child: SizedBox(width: 8),
            ),
            Icon(Icons.edit),
            Switch(
              value: campaignVM.isEditing,
              onChanged: (value) {
                campaignVM.isEditing = !campaignVM.isEditing;
              },
            ),
          ],
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text("•"),
      ),
      IconButton(
        onPressed: () {
          showSettingsDialog(context);
        },
        icon: Icon(Icons.settings),
      ),
      if (!isVertical(context))
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("•"),
        ),
      if (!isVertical(context))
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
              campaignVM.notificationCount = 0;
            },
            icon: badges.Badge(
              showBadge: campaignVM.notificationCount >
                  0, // Esconde se não houver notificações
              badgeContent: Text(
                campaignVM.notificationCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              position: badges.BadgePosition.topEnd(
                top: -10,
                end: -12,
              ), // Ajusta posição
              child: Icon(Icons.chat),
            ),
          ),
        ),
      SizedBox(width: 16),
    ],
  );
}
