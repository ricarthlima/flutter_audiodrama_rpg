import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/providers/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/expansible_list.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/dialogs/upinsert_battlemap_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/widgets/campaign_battlemap_grid_viewer.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/widgets/campaign_battlemap_item.dart';
import 'package:provider/provider.dart';

import '../../home/view/home_interact.dart';
import '../../campaign/widgets/list_settings.dart';
import '../../campaign/widgets/list_sheets_widget.dart';

class CampaignGridOwner extends StatelessWidget {
  const CampaignGridOwner({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignCTRL = context.watch<CampaignProvider>();
    final userProvider = context.watch<UserProvider>();

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 64, bottom: 8),
      child: SizedBox(
        width: width(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListSettings(showVisualControllers: false),
            Divider(),
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  Expanded(child: CampaignBattleMapGridViewer()),
                  VerticalDivider(),
                  SizedBox(
                    width: 400,
                    child: Column(
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
                                .map(
                                  (e) =>
                                      CampaignBattleMapListItem(battleMap: e),
                                )
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
                                .getMySheetsByCampaign(
                                  campaignCTRL.campaign!.id,
                                )
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
