import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
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
            InkWell(
              onTap: campaignPV.campaignScene != CampaignScenes.preview
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.preview;
                    }
                  : null,
              child: Text(
                "Visualização",
                style: TextStyle(
                  color: (campaignPV.campaignScene == CampaignScenes.preview)
                      ? AppColors.red
                      : AppColors.googleAuthBorderLight,
                  fontFamily: FontFamily.bungee,
                  fontSize: 18,
                ),
              ),
            ),
            InkWell(
              onTap: campaignPV.campaignScene != CampaignScenes.novel
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.novel;
                    }
                  : null,
              child: Text(
                "Ambientação",
                style: TextStyle(
                  color: (campaignPV.campaignScene == CampaignScenes.novel)
                      ? AppColors.red
                      : AppColors.googleAuthBorderLight,
                  fontFamily: FontFamily.bungee,
                  fontSize: 18,
                ),
              ),
            ),
            InkWell(
              onTap: campaignPV.campaignScene != CampaignScenes.grid
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.grid;
                    }
                  : null,
              child: Text(
                "Mapa de Batalha",
                style: TextStyle(
                  color: (campaignPV.campaignScene == CampaignScenes.grid)
                      ? AppColors.red
                      : AppColors.googleAuthBorderLight,
                  fontFamily: FontFamily.bungee,
                  fontSize: 18,
                ),
              ),
            ),
            InkWell(
              onTap: campaignPV.campaignScene != CampaignScenes.cutscenes
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.cutscenes;
                    }
                  : null,
              child: Text(
                "CENAS DE CORTE",
                style: TextStyle(
                  color: (campaignPV.campaignScene == CampaignScenes.cutscenes)
                      ? AppColors.red
                      : AppColors.googleAuthBorderLight,
                  fontFamily: FontFamily.bungee,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
