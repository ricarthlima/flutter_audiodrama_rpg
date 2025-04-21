import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/image_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/components/create_achievement.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (achievement.imageUrl == null ||
                    (achievement.isImageHided &&
                            !isPlayerUnlockedAchievement()) &&
                        !campaignVM.isEditing &&
                        !isUnlockedToAll(campaignVM))
                  Center(
                    child: Icon(
                      Icons.star_border,
                      size: 48,
                    ),
                  ),
                if (achievement.imageUrl != null &&
                    (!achievement.isImageHided ||
                        campaignVM.isEditing ||
                        isPlayerUnlockedAchievement() ||
                        isUnlockedToAll(campaignVM)))
                  Center(
                    child: InkWell(
                      onTap: () => showImageDialog(
                        context: context,
                        imageUrl: achievement.imageUrl!,
                      ),
                      child: Image.network(
                        achievement.imageUrl!,
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 175,
                      child: Tooltip(
                        message: achievement.title,
                        child: Expanded(
                          child: Text(
                            achievement.title,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!achievement.isDescriptionHided ||
                        (campaignVM.isOwner && campaignVM.isEditing) ||
                        isPlayerUnlockedAchievement() ||
                        isUnlockedToAll(campaignVM))
                      SizedBox(
                        width: 175,
                        child: Text(
                          achievement.description,
                        ),
                      ),
                    if (!campaignVM.isEditing && !isPlayerUnlockedAchievement())
                      SizedBox(height: 8),
                  ],
                ),
              ],
            ),
            if (!campaignVM.isEditing && !isPlayerUnlockedAchievement())
              Opacity(
                opacity: 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    if (isUnlockedToAll(campaignVM))
                      Tooltip(
                        message: "Desbloqueado para todas as pessoas",
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.green,
                        ),
                      ),
                    if (achievement.isHided && !isUnlockedToAll(campaignVM))
                      Tooltip(
                        message: "Conquista oculta",
                        child: Icon(Icons.visibility_off),
                      ),
                    if (achievement.isImageHided &&
                        !isUnlockedToAll(campaignVM))
                      Tooltip(
                        message: "Imagem oculta",
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    if (achievement.isDescriptionHided &&
                        !isUnlockedToAll(campaignVM))
                      Tooltip(
                        message: "Descrição oculta",
                        child: Icon(Icons.texture_rounded),
                      ),
                  ],
                ),
              ),
            if (campaignVM.isOwner)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Divider(thickness: 0.25),
                  if (!isUnlockedToAll(campaignVM))
                    ElevatedButton(
                      onPressed: () {
                        unlockToAllUsers(context, campaignVM);
                      },
                      child: Text("Liberar geral"),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showCreateEditAchievementDialog(
                        context: context,
                        achievement: achievement,
                      );
                    },
                    icon: Icon(Icons.edit),
                    label: Text("Editar"),
                  ),
                  Tooltip(
                    message: "Pressione longamente para remover",
                    child: ElevatedButton.icon(
                      onLongPress: () {
                        campaignVM.onRemoveAchievement(achievement);
                      },
                      onPressed: () {},
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                        AppColors.redDark,
                      )),
                      label: Text(
                        "Remover",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void unlockToAllUsers(
      BuildContext context, CampaignViewModel campaignVM) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Liberar para todo mundo?"),
          content: Text(
              'Essa ação notificará todas as pessoas com a conquista "${achievement.title}."'),
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
    return achievement.listUsers
        .contains(FirebaseAuth.instance.currentUser!.uid);
  }

  isUnlockedToAll(CampaignViewModel campaignVM) {
    List<String> a = achievement.listUsers;
    List<String> b = campaignVM.campaign!.listIdPlayers;
    return Set.from(a).containsAll(b) && Set.from(b).containsAll(a);
  }
}

// class AchievementWidget extends StatelessWidget {
//   final CampaignAchievement achievement;
//   const AchievementWidget({super.key, required this.achievement});

//   @override
//   Widget build(BuildContext context) {
//     CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(context);
//     return Visibility(
//       visible: !achievement.isHided ||
//           campaignVM.isOwner ||
//           isPlayerUnlockedAchievement(),
//       child: Container(
//         width: 250,
//         constraints: BoxConstraints(minHeight: 250),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(75),
//           border: Border.all(
//             width: 4,
//             color: (isPlayerUnlockedAchievement())
//                 ? Colors.green
//                 : Colors.transparent,
//           ),
//         ),
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           spacing: 8,
//           children: [
//             if (achievement.imageUrl == null ||
//                 (achievement.isImageHided && !isPlayerUnlockedAchievement()) &&
//                     !campaignVM.isEditing &&
//                     !isUnlockedToAll(campaignVM))
//               Center(
//                 child: Icon(
//                   Icons.star_border,
//                   size: 128,
//                 ),
//               ),
//             if (achievement.imageUrl != null &&
//                 (!achievement.isImageHided ||
//                     campaignVM.isEditing ||
//                     isPlayerUnlockedAchievement() ||
//                     isUnlockedToAll(campaignVM)))
//               Center(
//                 child: InkWell(
//                   onTap: () => showImageDialog(
//                     context: context,
//                     imageUrl: achievement.imageUrl!,
//                   ),
//                   child: Image.network(
//                     achievement.imageUrl!,
//                     width: 128,
//                     height: 128,
//                   ),
//                 ),
//               ),
//             Center(
//               child: Text(
//                 achievement.title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//             if (!achievement.isDescriptionHided ||
//                 (campaignVM.isOwner && campaignVM.isEditing) ||
//                 isPlayerUnlockedAchievement() ||
//                 isUnlockedToAll(campaignVM))
//               Text(achievement.description),
//             if (!campaignVM.isEditing && !isPlayerUnlockedAchievement())
//               Opacity(
//                 opacity: 0.5,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   spacing: 16,
//                   children: [
//                     if (isUnlockedToAll(campaignVM))
//                       Tooltip(
//                         message: "Desbloqueado para todas as pessoas",
//                         child: Icon(
//                           Icons.emoji_events,
//                           color: Colors.green,
//                         ),
//                       ),
//                     if (achievement.isHided && !isUnlockedToAll(campaignVM))
//                       Tooltip(
//                         message: "Conquista oculta",
//                         child: Icon(Icons.visibility_off),
//                       ),
//                     if (achievement.isImageHided &&
//                         !isUnlockedToAll(campaignVM))
//                       Tooltip(
//                         message: "Imagem oculta",
//                         child: Icon(Icons.image_not_supported_outlined),
//                       ),
//                     if (achievement.isDescriptionHided &&
//                         !isUnlockedToAll(campaignVM))
//                       Tooltip(
//                         message: "Descrição oculta",
//                         child: Icon(Icons.texture_rounded),
//                       ),
//                   ],
//                 ),
//               ),
//             if (campaignVM.isOwner && campaignVM.isEditing)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Divider(),
//                   CheckboxListTile(
//                     title: Text("Conquista oculta?"),
//                     contentPadding: EdgeInsets.zero,
//                     value: achievement.isHided,
//                     onChanged: (value) {
//                       campaignVM.updateAchievement(
//                         achievement.copyWith(isHided: !achievement.isHided),
//                       );
//                     },
//                   ),
//                   CheckboxListTile(
//                     title: Text("Ocultar imagem?"),
//                     contentPadding: EdgeInsets.zero,
//                     value: achievement.isImageHided,
//                     onChanged: (value) {
//                       campaignVM.updateAchievement(
//                         achievement.copyWith(
//                           isImageHided: !achievement.isImageHided,
//                         ),
//                       );
//                     },
//                   ),
//                   CheckboxListTile(
//                     title: Text("Ocultar descrição?"),
//                     contentPadding: EdgeInsets.zero,
//                     value: achievement.isDescriptionHided,
//                     onChanged: (value) {
//                       campaignVM.updateAchievement(
//                         achievement.copyWith(
//                           isDescriptionHided: !achievement.isDescriptionHided,
//                         ),
//                       );
//                     },
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       showManageAchievementPlayersDialog(
//                         context: context,
//                         achievement: achievement,
//                       );
//                     },
//                     child: Text("Gerenciar"),
//                   ),
//                 ],
//               ),
//             if (campaignVM.isOwner && !isUnlockedToAll(campaignVM))
//               ElevatedButton(
//                 onPressed: () {
//                   unlockToAllUsers(context, campaignVM);
//                 },
//                 child: Text("Liberar geral"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void unlockToAllUsers(
//       BuildContext context, CampaignViewModel campaignVM) async {
//     bool? result = await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Liberar para todo mundo?"),
//           content: Text(
//               'Essa ação notificará todas as pessoas com a conquista "${achievement.title}."'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text("Cancelar"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               child: Text("Liberar"),
//             ),
//           ],
//         );
//       },
//     );

//     if (result != null && result) {
//       campaignVM.unlockToAllUsers(achievement);
//     }
//   }

//   bool isPlayerUnlockedAchievement() {
//     return achievement.listUsers
//         .contains(FirebaseAuth.instance.currentUser!.uid);
//   }

//   isUnlockedToAll(CampaignViewModel campaignVM) {
//     List<String> a = achievement.listUsers;
//     List<String> b = campaignVM.campaign!.listIdPlayers;
//     return Set.from(a).containsAll(b) && Set.from(b).containsAll(a);
//   }
// }
