import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/tab_title.dart';
import 'package:provider/provider.dart';
import '../utils/campaign_scenes.dart';
import '../view/campaign_view_model.dart';

class ListSettings extends StatelessWidget {
  const ListSettings({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignPV = Provider.of<CampaignProvider>(context);

    return Column(
      children: [
        Row(
          spacing: 16,
          children: [
            TabTitle(
              title: "Visualização",
              isActive: campaignPV.campaignScene == CampaignScenes.preview,
              onTap: campaignPV.campaignScene != CampaignScenes.preview
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.preview;
                    }
                  : null,
            ),
            TabTitle(
              title: "Ambientação",
              isActive: campaignPV.campaignScene == CampaignScenes.novel,
              onTap: campaignPV.campaignScene != CampaignScenes.novel
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.novel;
                    }
                  : null,
            ),
            TabTitle(
              title: "Mesa de Batalha",
              isActive: campaignPV.campaignScene == CampaignScenes.grid,
              onTap: campaignPV.campaignScene != CampaignScenes.grid
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.grid;
                    }
                  : null,
            ),
            TabTitle(
              title: "Cenas de Corte",
              isActive: campaignPV.campaignScene == CampaignScenes.cutscenes,
              onTap: campaignPV.campaignScene != CampaignScenes.cutscenes
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.cutscenes;
                    }
                  : null,
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
