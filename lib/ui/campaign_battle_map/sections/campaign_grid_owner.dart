import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/campaign_sheet_item.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../_core/widgets/expansible_list.dart';
import '../../_core/widgets/horizontal_split_view.dart';
import '../../campaign/dialogs/upinsert_battlemap_dialog.dart';
import '../../campaign/view/campaign_view_model.dart';
import '../widgets/campaign_battlemap_grid_viewer.dart';
import '../widgets/campaign_battlemap_item.dart';

class CampaignGridOwner extends StatelessWidget {
  const CampaignGridOwner({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignCTRL = context.watch<CampaignProvider>();
    final userProvider = context.watch<UserProvider>();

    return HorizontalSplitView(
      initialRatio: 0.75,
      dividerThickness: 5,

      left: CampaignBattleMapGridViewer(),
      right: Column(
        children: [
          ExpansibleList(
            title: "Mapas de Batalha",
            actions: [
              IconButton(
                onPressed: () {
                  showUpinsertBattleMap(context);
                },
                icon: Icon(Icons.add),
              ),
            ],
            child: Column(
              children: campaignCTRL.campaign!.listBattleMaps
                  .map((e) => CampaignBattleMapListItem(battleMap: e))
                  .toList(),
            ),
          ),
          ExpansibleList(
            title: "Objetos",
            startClosed: true,
            child: Column(children: []),
          ),
          ExpansibleList(
            title: "Meus Personagens",
            startClosed: true,
            child: Column(
              children: userProvider
                  .getMySheetsByCampaign(campaignCTRL.campaign!.id)
                  .map((e) {
                    final sau = SheetAppUser(
                      sheet: e,
                      appUser: userProvider.currentAppUser,
                    );
                    return CampaignSheetItem(
                      sheet: sau.sheet,
                      username: sau.appUser.username!,
                    );
                  })
                  .toList(),
            ),
          ),
          ExpansibleList(
            title: "Outros Personagens",
            startClosed: true,
            child: Column(
              children: campaignCTRL.listSheetAppUser.map((sau) {
                return CampaignSheetItem(
                  sheet: sau.sheet,
                  username: sau.appUser.username!,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );

    // Row(
    //   spacing: 8,
    //   children: [
    //     Expanded(child: ),
    //     VerticalDivider(),
    //    ],
    // );
  }
}
