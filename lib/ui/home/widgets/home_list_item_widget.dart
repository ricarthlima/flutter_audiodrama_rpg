import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/app_user.dart';
import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/helpers.dart';
import '../../_core/web/download_json/download_json.dart';
import '../components/move_sheet_to_campaign_dialog.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../../_core/components/image_dialog.dart';
import '../../campaign/view/campaign_view_model.dart';
import '../view/home_interact.dart';
import '../view/home_view_model.dart';

class HomeListItemWidget extends StatelessWidget {
  final Sheet sheet;
  final String username;
  final bool isShowingByCampaign;
  final AppUser? appUser;
  final Function? onDetach;

  const HomeListItemWidget({
    super.key,
    required this.sheet,
    required this.username,
    this.isShowingByCampaign = false,
    this.appUser,
    this.onDetach,
  });

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);
    return ListTile(
      leading: SizedBox(
        height: isVertical(context) ? 32 : 64,
        width: isVertical(context) ? 32 : 64,
        child: (sheet.imageUrl != null)
            ? InkWell(
                onTap: () {
                  showImageDialog(
                    context: context,
                    imageUrl: sheet.imageUrl!,
                  );
                },
                child: Container(
                  decoration: isVertical(context)
                      ? null
                      : BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                  height: isVertical(context) ? 32 : 64,
                  width: isVertical(context) ? 32 : 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      sheet.imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      height: isVertical(context) ? 32 : 64,
                      width: isVertical(context) ? 32 : 64,
                    ),
                  ),
                ),
              )
            : Icon(
                Icons.feed,
                size: isVertical(context) ? 26 : 40,
              ),
      ),
      title: Text(
        sheet.characterName,
        style: TextStyle(
          fontSize: (isVertical(context)) ? 16 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              downloadJsonFile(sheet.toMapWithoutId(),
                  "sheet-${sheet.characterName.toLowerCase().replaceAll(" ", "_")}.json");
            },
            tooltip: "Exportar",
            icon: Icon(Icons.file_download_outlined),
          ),
          if (isShowingByCampaign)
            IconButton(
              onPressed: () {
                AppRouter().goSheet(
                  context: context,
                  username: username,
                  sheet: sheet,
                  isPushing: isShowingByCampaign,
                );
              },
              tooltip: "Abrir nessa tela",
              icon: Icon(Icons.arrow_forward),
            ),
          (sheet.ownerId == FirebaseAuth.instance.currentUser!.uid &&
                  !isVertical(context))
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () {
                        showMoveSheetToCampaignDialog(
                          context: context,
                          sheet: sheet,
                        );
                      },
                      tooltip: "Mover para campanha",
                      icon: Icon(Icons.move_down_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        homeVM.onDuplicateSheet(sheet: sheet);
                      },
                      tooltip: "Duplicar",
                      icon: Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () {
                        HomeInteract.onRemoveSheet(
                          context: context,
                          sheet: sheet,
                        );
                      },
                      tooltip: "Remover",
                      icon: Icon(
                        Icons.delete,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                )
              : IconButton(
                  onPressed: () {
                    String? campaignId =
                        context.read<CampaignViewModel>().campaign?.id;
                    homeVM.onDuplicateSheetToMe(
                      campaignId: campaignId,
                      sheet: sheet,
                    );
                  },
                  tooltip: "Duplicar",
                  icon: Icon(Icons.copy),
                ),
        ],
      ),
      subtitle: Opacity(
        opacity: 0.90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isShowingByCampaign && appUser != null)
              Text(appUser!.username!),
            // if (appUser != null) Divider(thickness: 0.2),
            Row(
              spacing: 4,
              children: [
                Text(
                  "Experiência:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(getBaseLevel(sheet.baseLevel)),
              ],
            ),
            // if (!isShowingByCampaign)
            //   Row(
            //     spacing: 4,
            //     children: [
            //       Text(
            //         "Na campanha:",
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //       Text(
            //           homeSheetVM.getWorldName(context: context, sheet: sheet)),
            //     ],
            //   ),
          ],
        ),
      ),
      onTap: () {
        if (isShowingByCampaign) {
          if (onDetach != null) {
            onDetach!();
          }
        } else {
          AppRouter().goSheet(
            context: context,
            username: username,
            sheet: sheet,
            isPushing: isShowingByCampaign,
          );
        }
      },
    );
  }
}
