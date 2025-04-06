import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/helpers.dart';
import 'package:flutter_rpg_audiodrama/ui/home/components/move_sheet_to_campaign_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_sheet_view_model.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/sheet_model.dart';
import '../../_core/components/image_dialog.dart';
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
    final viewModel = Provider.of<HomeViewModel>(context);
    final homeSheetVM = Provider.of<HomeSheetViewModel>(context);
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
          if (isShowingByCampaign)
            IconButton(
              onPressed: () {
                viewModel.goToSheet(
                  context,
                  sheet: sheet,
                  username: username,
                  isPushing: isShowingByCampaign,
                );
              },
              iconSize: (isVertical(context)) ? 20 : 32,
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
                      iconSize: (isVertical(context)) ? 20 : 32,
                      tooltip: "Mover para campanha",
                      icon: Icon(Icons.move_down_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        viewModel.onDuplicateSheet(
                            context: context, sheet: sheet);
                      },
                      iconSize: (isVertical(context)) ? 20 : 32,
                      tooltip: "Duplicar",
                      icon: Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () {
                        viewModel.onRemoveSheet(context: context, sheet: sheet);
                      },
                      iconSize: (isVertical(context)) ? 20 : 32,
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
                    viewModel.onDuplicateSheetToMe(
                        context: context, sheet: sheet);
                  },
                  iconSize: (isVertical(context)) ? 20 : 32,
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
            if (!isShowingByCampaign)
              Row(
                spacing: 4,
                children: [
                  Text(
                    "Na campanha:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                      homeSheetVM.getWorldName(context: context, sheet: sheet)),
                ],
              ),
          ],
        ),
      ),
      onTap: () {
        if (isShowingByCampaign) {
          if (onDetach != null) {
            onDetach!();
          }
        } else {
          viewModel.goToSheet(
            context,
            sheet: sheet,
            username: username,
            isPushing: isShowingByCampaign,
          );
        }
      },
    );
  }
}
