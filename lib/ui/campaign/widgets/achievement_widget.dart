import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/campaign_achievement.dart';
import '../../_core/app_colors.dart';
import '../../_core/components/image_dialog.dart';
import '../components/create_achievement.dart';
import '../components/manage_achievement_players.dart';
import '../view/campaign_view_model.dart';
import 'package:provider/provider.dart';

class AchievementWidget extends StatelessWidget {
  final CampaignAchievement achievement;
  const AchievementWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    CampaignProvider campaignVM = Provider.of<CampaignProvider>(context);
    return Visibility(
      visible:
          !achievement.isHided ||
          campaignVM.isOwner ||
          isPlayerUnlockedAchievement(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(75),
          border: Border.all(
            width: 4,
            color: (isPlayerUnlockedAchievement())
                ? Colors.green
                : Colors.transparent,
          ),
        ),
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (_getShowIconCondition(campaignVM))
                  Icon(Icons.star_border, size: 48),
                if (_getShowImageCondition(campaignVM))
                  InkWell(
                    onTap: () => showImageDialog(
                      context: context,
                      imageUrl: achievement.imageUrl!,
                    ),
                    child: Image.network(
                      achievement.imageUrl ?? '',
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image);
                      },
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      if (_getShowDescriptionCondition(campaignVM))
                        Text(achievement.description),
                      if (!_getShowDescriptionCondition(campaignVM))
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            "Descrição oculta",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      if (!campaignVM.isEditing &&
                          !isPlayerUnlockedAchievement())
                        SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            // if (_getShowLiberarGeralCondition(campaignVM))
            //   Opacity(
            //     opacity: 0.5,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       spacing: 16,
            //       children: [
            //         if (isUnlockedToAll(campaignVM))
            //           Tooltip(
            //             message: "Desbloqueado para todas as pessoas",
            //             child: Icon(
            //               Icons.emoji_events,
            //               color: Colors.green,
            //             ),
            //           ),
            //         if (achievement.isHided && !isUnlockedToAll(campaignVM))
            //           Tooltip(
            //             message: "Conquista oculta",
            //             child: Icon(Icons.visibility_off),
            //           ),
            //         if (achievement.isImageHided &&
            //             !isUnlockedToAll(campaignVM))
            //           Tooltip(
            //             message: "Imagem oculta",
            //             child: Icon(Icons.image_not_supported_outlined),
            //           ),
            //         if (achievement.isDescriptionHided &&
            //             !isUnlockedToAll(campaignVM))
            //           Tooltip(
            //             message: "Descrição oculta",
            //             child: Icon(Icons.texture_rounded),
            //           ),
            //       ],
            //     ),
            //   ),
            if (campaignVM.isOwner)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Divider(thickness: 0.25),
                  Row(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: ElevatedButton.icon(
                          onPressed: (!isUnlockedToAll(campaignVM))
                              ? () {
                                  unlockToAllUsers(context, campaignVM);
                                }
                              : null,
                          icon: Icon(Icons.emoji_events, color: Colors.white),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey[800]!;
                              }
                              return Colors.green[900]!;
                            }),
                          ),
                          label: Tooltip(
                            message: !isUnlockedToAll(campaignVM)
                                ? "Liberar a conquista para todas as pessoas jogadoras"
                                : "Todas já possuem a conquista",
                            child: Text(
                              "Liberar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: ElevatedButton(
                          onPressed: () {
                            showManageAchievementPlayersDialog(
                              context: context,
                              achievement: achievement,
                            );
                          },
                          child: Text("Gerenciar"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showCreateEditAchievementDialog(
                              context: context,
                              achievement: achievement,
                            );
                          },
                          icon: Icon(Icons.edit),
                          label: Text("Editar"),
                        ),
                      ),
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: Tooltip(
                          message: "Pressione longamente para remover",
                          child: ElevatedButton.icon(
                            onLongPress: () {
                              campaignVM.onRemoveAchievement(achievement);
                            },
                            onPressed: () {},
                            icon: Icon(Icons.delete, color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                AppColors.redDark,
                              ),
                            ),
                            label: Text(
                              "Remover",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // bool _getShowLiberarGeralCondition(CampaignViewModel campaignVM) =>
  //     !campaignVM.isEditing && !isPlayerUnlockedAchievement();

  bool _getShowDescriptionCondition(CampaignProvider campaignVM) {
    return !achievement.isDescriptionHided ||
        (campaignVM.isOwner && campaignVM.isEditing) ||
        isPlayerUnlockedAchievement() ||
        isUnlockedToAll(campaignVM);
  }

  bool _getShowImageCondition(CampaignProvider campaignVM) {
    return achievement.imageUrl != null &&
        (!achievement.isImageHided ||
            campaignVM.isEditing ||
            isPlayerUnlockedAchievement() ||
            isUnlockedToAll(campaignVM));
  }

  bool _getShowIconCondition(CampaignProvider campaignVM) {
    return achievement.imageUrl == null ||
        (achievement.isImageHided && !isPlayerUnlockedAchievement()) &&
            !campaignVM.isEditing &&
            !isUnlockedToAll(campaignVM);
  }

  void unlockToAllUsers(
    BuildContext context,
    CampaignProvider campaignVM,
  ) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Liberar para todo mundo?"),
          content: Text(
            'Essa ação notificará todas as pessoas com a conquista "${achievement.title}."',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Liberar"),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      campaignVM.unlockToAllUsers(achievement);
    }
  }

  bool isPlayerUnlockedAchievement() {
    return achievement.listUsers.contains(
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  bool isUnlockedToAll(CampaignProvider campaignVM) {
    List<String> a = achievement.listUsers;
    List<String> b = campaignVM.campaign!.listIdPlayers;
    return Set.from(a).containsAll(b) && Set.from(b).containsAll(a);
  }
}
