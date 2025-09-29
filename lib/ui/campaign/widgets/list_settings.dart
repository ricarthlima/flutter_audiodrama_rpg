import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/tutorial_populate_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_scenes.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'package:provider/provider.dart';

class ListSettings extends StatelessWidget {
  final bool showVisualControllers;
  const ListSettings({super.key, this.showVisualControllers = true});

  @override
  Widget build(BuildContext context) {
    CampaignVisualNovelViewModel visualVM =
        Provider.of<CampaignVisualNovelViewModel>(context);

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
        if (showVisualControllers)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showTutorialServer(context);
                  },
                  icon: Icon(Icons.podcasts),
                  label: Text("Servidor"),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    visualVM.onRemove();
                  },
                  icon: Icon(Icons.delete_forever),
                  label: Text("Excluir tudo"),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
