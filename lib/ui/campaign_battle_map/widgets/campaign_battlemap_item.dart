import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/app_colors.dart';
import '../../_core/components/remove_dialog.dart';
import '../../campaign/view/campaign_view_model.dart';
import '../controllers/battle_map_controller.dart';
import '../models/battle_map.dart';

class CampaignBattleMapListItem extends StatelessWidget {
  final BattleMap battleMap;
  const CampaignBattleMapListItem({super.key, required this.battleMap});

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final battleMapProvider = context.watch<CampaignOwnerBattleMapProvider>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(
          width: 4,
          color: campaignProvider.campaign!.activeBattleMapId == battleMap.id
              ? AppColors.red
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: () {
          battleMapProvider.onInitialize(battleMap);
        },
        contentPadding: EdgeInsets.zero,
        leading: AspectRatio(
          aspectRatio: 5 / 4,
          child: Image.network(battleMap.imageUrl, fit: BoxFit.cover),
        ),
        title: Text(battleMap.name),
        subtitle: Text("${battleMap.columns} x ${battleMap.rows}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (campaignProvider.campaign!.activeBattleMapId ==
                    battleMap.id) {
                  campaignProvider.deactivateGlobalBattleMap();
                } else {
                  campaignProvider.activeGlobalBattleMap(battleMap);
                }
              },
              icon: Icon(
                (campaignProvider.campaign!.activeBattleMapId == battleMap.id)
                    ? Icons.stop
                    : Icons.play_arrow,
              ),
            ),
            IconButton(
              onPressed: () {
                showRemoveDialog(
                  context: context,
                  message: "Deseja remover ${battleMap.name}?",
                ).then((value) {
                  if (value != null && value) {
                    campaignProvider.removeBattleMap(battleMap);
                  }
                });
              },
              icon: Icon(Icons.delete, color: AppColors.red),
            ),
          ],
        ),
      ),
    );
  }
}
