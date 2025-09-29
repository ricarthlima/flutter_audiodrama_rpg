import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../_core/widgets/expansible_list.dart';
import '../../_core/widgets/horizontal_split_view.dart';
import '../../campaign/dialogs/upinsert_battlemap_dialog.dart';
import '../../campaign/view/campaign_view_model.dart';
import '../../campaign/widgets/list_sheets_widget.dart';
import '../../home/view/home_interact.dart';
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
            child: Column(children: []),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: ListSheetsWidget(
              title: "Meus personagens",
              actions: [
                IconButton(
                  onPressed: () {
                    HomeInteract.onCreateCharacterClicked(
                      context,
                      campaignId: campaignCTRL.campaign?.id,
                    );
                  },
                  tooltip: "Criar personagem",
                  icon: Icon(Icons.add),
                ),
              ],
              listSheetsAppUser: userProvider
                  .getMySheetsByCampaign(campaignCTRL.campaign!.id)
                  .map(
                    (e) => SheetAppUser(
                      sheet: e,
                      appUser: userProvider.currentAppUser,
                    ),
                  )
                  .toList(),
              showExpand: true,
            ),
          ),
          if (campaignCTRL.isOwner)
            Flexible(
              fit: FlexFit.loose,
              child: ListSheetsWidget(
                title: "Outros personagens",
                listSheetsAppUser: campaignCTRL.listSheetAppUser,
                showExpand: true,
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
