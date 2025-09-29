import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/campaign_achievement.dart';
import '../../_core/widgets/generic_header.dart';
import '../components/create_achievement.dart';
import '../view/campaign_view_model.dart';
import '../widgets/achievement_widget.dart';

class CampaignAchievementsWidget extends StatelessWidget {
  const CampaignAchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenericHeader(
          title: "Conquistas",
          iconButton: (campaignVM.isOwner)
              ? IconButton(
                  onPressed: () {
                    showCreateEditAchievementDialog(context: context);
                  },
                  icon: Icon(Icons.add),
                )
              : null,
        ),
        Expanded(
          child: ListView(
            children: _generateListAchievementsWidget(context, campaignVM),
          ),
        ),
      ],
    );
  }

  List<Widget> _generateListAchievementsWidget(
    BuildContext context,
    CampaignProvider campaignVM,
  ) {
    // Dono editando, vê tudo.
    if (campaignVM.isOwner) {
      return campaignVM.campaign!.listAchievements.map((achievement) {
        return AchievementWidget(achievement: achievement);
      }).toList();
    }

    List<CampaignAchievement> listNotHided = campaignVM
        .campaign!
        .listAchievements
        .where(
          (e) =>
              !e.isHided ||
              e.listUsers.contains(FirebaseAuth.instance.currentUser!.uid),
        )
        .toList();

    int totalHided =
        campaignVM.campaign!.listAchievements.length - listNotHided.length;

    List<Widget> listReturn = [];

    List<CampaignAchievement> listHave = listNotHided
        .where(
          (e) => e.listUsers.contains(FirebaseAuth.instance.currentUser!.uid),
        )
        .toList();

    List<CampaignAchievement> listDontHave = listNotHided
        .where(
          (e) => !e.listUsers.contains(FirebaseAuth.instance.currentUser!.uid),
        )
        .toList();

    listHave.sort((a, b) => a.title.compareTo(b.title));
    listDontHave.sort((a, b) => a.title.compareTo(b.title));

    listReturn.addAll(
      listHave.map((achievement) {
        return AchievementWidget(achievement: achievement);
      }),
    );

    listReturn.addAll(
      listDontHave.map((achievement) {
        return AchievementWidget(achievement: achievement);
      }),
    );

    if (totalHided > 0) {
      listReturn.add(
        Container(
          width: 250,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 4,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withAlpha(90),
            ),
          ),
          child: Center(
            child: Text(
              "E mais $totalHided conquista${(totalHided != 1) ? 's' : ''} oculta${(totalHided != 1) ? 's' : ''}.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }
    return listReturn;
  }
}
