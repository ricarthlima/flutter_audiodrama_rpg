import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/create_achievement.dart';
import 'package:provider/provider.dart';

import '../view/campaign_view_model.dart';

class CampaignAchievementsScreen extends StatelessWidget {
  const CampaignAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    return Column(
      children: [
        GenericHeader(
          title: "Conquistas",
          iconButton: (campaignVM.isOwner)
              ? IconButton(
                  onPressed: () {
                    showCreateAchievementDialog(context: context);
                  },
                  icon: Icon(Icons.add),
                )
              : null,
        ),
      ],
    );
  }
}
