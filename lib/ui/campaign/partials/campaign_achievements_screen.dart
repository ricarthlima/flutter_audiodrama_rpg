import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/create_achievement.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/widgets/achievement_widget.dart';
import 'package:provider/provider.dart';

import '../view/campaign_view_model.dart';

class CampaignAchievementsScreen extends StatelessWidget {
  const CampaignAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (campaignVM.isOwner && !campaignVM.isEditing)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
                "Visualização de pessoa jogadora, entre em modo edição para fazer alterações. Pessoas jogadoras veem integralmente conquistas que já desbloquearam."),
          ),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 8,
          runSpacing: 16,
          children: _generateListAchievementsWidget(context, campaignVM),
        )
      ],
    );
  }

  List<Widget> _generateListAchievementsWidget(
      BuildContext context, CampaignViewModel campaignVM) {
    // Dono editando, vê tudo.
    if (campaignVM.isOwner && campaignVM.isEditing) {
      return campaignVM.campaign!.listAchievements.map((achievement) {
        return AchievementWidget(achievement: achievement);
      }).toList();
    }

    List<CampaignAchievement> listNotHided =
        campaignVM.campaign!.listAchievements
            .where(
              (e) =>
                  !e.isHided ||
                  e.listUsers.contains(FirebaseAuth.instance.currentUser!.uid),
            )
            .toList();

    int totalHided =
        campaignVM.campaign!.listAchievements.length - listNotHided.length;

    List<Widget> listReturn = [];
    listReturn.addAll(listNotHided.map((achievement) {
      return AchievementWidget(achievement: achievement);
    }));
    listReturn.add(
      Container(
        width: 232,
        height: 232,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 4,
            color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(90),
          ),
        ),
        child: Center(
          child: Text(
            "E mais $totalHided conquista${(totalHided > 1) ? 's' : ''} oculta${(totalHided > 1) ? 's' : ''}.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
    return listReturn;
  }
}
