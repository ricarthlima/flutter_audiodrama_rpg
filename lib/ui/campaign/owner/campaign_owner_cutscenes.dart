import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/wip_snackbar.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/owner/widgets/campaign_owner_cutscene_item.dart';

class CampaignOwnerCutscenes extends StatelessWidget {
  const CampaignOwnerCutscenes({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            "Principais",
            style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Abertura",
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 16),
              ),
              CampaignOwnerCutsceneItem(title: "my_great_opening.mp4"),
            ],
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Encerramento",
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 16),
              ),
              CampaignOwnerCutsceneItem(title: "my_great_ending.mp4"),
            ],
          ),
          Divider(thickness: 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Outros",
                style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 24),
              ),
              IconButton(
                onPressed: () {
                  showSnackBarWip(context);
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampaignOwnerCutsceneItem(title: "some_cutscene.mp4"),
                CampaignOwnerCutsceneItem(title: "other_cutscene.mp4"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
