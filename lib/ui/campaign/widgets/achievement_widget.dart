import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/image_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/manage_achievement_players.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import 'package:provider/provider.dart';

class AchievementWidget extends StatelessWidget {
  final CampaignAchievement achievement;
  const AchievementWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
    return Visibility(
      visible: !achievement.isHided ||
          campaignVM.isOwner ||
          isPlayerUnlockedAchievement(),
      child: Container(
        width: 250,
        constraints: BoxConstraints(minHeight: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(75),
          border: Border.all(
            width: 4,
            color: (isPlayerUnlockedAchievement())
                ? Colors.green
                : Colors.transparent,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            if (achievement.imageUrl == null ||
                (achievement.isImageHided && !isPlayerUnlockedAchievement()) &&
                    !campaignVM.isEditing)
              Center(
                child: Icon(
                  Icons.star_border,
                  size: 128,
                ),
              ),
            if (achievement.imageUrl != null &&
                (!achievement.isImageHided ||
                    campaignVM.isEditing ||
                    isPlayerUnlockedAchievement()))
              Center(
                child: InkWell(
                  onTap: () => showImageDialog(
                    context: context,
                    imageUrl: achievement.imageUrl!,
                  ),
                  child: Image.network(
                    achievement.imageUrl!,
                    width: 128,
                    height: 128,
                  ),
                ),
              ),
            Center(
              child: Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            if (!achievement.isDescriptionHided ||
                (campaignVM.isOwner && campaignVM.isEditing) ||
                isPlayerUnlockedAchievement())
              Text(achievement.description),
            if (!campaignVM.isEditing && !isPlayerUnlockedAchievement())
              Opacity(
                opacity: 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    if (achievement.isHided)
                      Tooltip(
                        message: "Conquista oculta",
                        child: Icon(Icons.visibility_off),
                      ),
                    if (achievement.isImageHided)
                      Tooltip(
                        message: "Imagem oculta",
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    if (achievement.isDescriptionHided)
                      Tooltip(
                        message: "Descrição oculta",
                        child: Icon(Icons.texture_rounded),
                      ),
                  ],
                ),
              ),
            if (campaignVM.isOwner && campaignVM.isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(),
                  CheckboxListTile(
                    title: Text("Conquista oculta?"),
                    contentPadding: EdgeInsets.zero,
                    value: achievement.isHided,
                    onChanged: (value) {
                      campaignVM.updateAchievement(
                        achievement.copyWith(isHided: !achievement.isHided),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Ocultar imagem?"),
                    contentPadding: EdgeInsets.zero,
                    value: achievement.isImageHided,
                    onChanged: (value) {
                      campaignVM.updateAchievement(
                        achievement.copyWith(
                          isImageHided: !achievement.isImageHided,
                        ),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Ocultar descrição?"),
                    contentPadding: EdgeInsets.zero,
                    value: achievement.isDescriptionHided,
                    onChanged: (value) {
                      campaignVM.updateAchievement(
                        achievement.copyWith(
                          isDescriptionHided: !achievement.isDescriptionHided,
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showManageAchievementPlayersDialog(
                        context: context,
                        achievement: achievement,
                      );
                    },
                    child: Text("Gerenciar"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool isPlayerUnlockedAchievement() {
    return achievement.listUsers
        .contains(FirebaseAuth.instance.currentUser!.uid);
  }
}
