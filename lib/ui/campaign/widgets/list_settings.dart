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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Row(
          spacing: 16,
          children: [
            InkWell(
              onTap: campaignPV.campaignScene != CampaignScenes.visual
                  ? () {
                      campaignPV.campaignScene = CampaignScenes.visual;
                    }
                  : null,
              child: Text(
                "Mesa de Ambientação",
                style: TextStyle(
                  color: (campaignPV.campaignScene == CampaignScenes.visual)
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
          ],
        ),
      ],
    );
  }
}
