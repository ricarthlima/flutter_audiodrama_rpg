import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
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

  const HomeListItemWidget({
    super.key,
    required this.sheet,
    required this.username,
    this.isShowingByCampaign = false,
    this.appUser,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final homeSheetVM = Provider.of<HomeSheetViewModel>(context);
    return ListTile(
      leading: (sheet.imageUrl != null)
          ? InkWell(
              onTap: () {
                showImageDialog(
                  context: context,
                  imageUrl: sheet.imageUrl!,
                );
              },
              child: ClipOval(
                child: Image.network(
                  sheet.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Icon(
              Icons.feed,
              size: 40,
            ),
      title: Text(
        sheet.characterName,
        style: TextStyle(
          fontSize: (isVertical(context)) ? 16 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: (sheet.ownerId == FirebaseAuth.instance.currentUser!.uid)
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
                  iconSize: (isVertical(context)) ? 24 : 32,
                  tooltip: "Mover para campanha",
                  icon: Icon(Icons.move_down_rounded),
                ),
                IconButton(
                  onPressed: () {
                    viewModel.onDuplicateSheet(context: context, sheet: sheet);
                  },
                  iconSize: (isVertical(context)) ? 24 : 32,
                  tooltip: "Duplicar",
                  icon: Icon(Icons.copy),
                ),
                IconButton(
                  onPressed: () {
                    viewModel.onRemoveSheet(context: context, sheet: sheet);
                  },
                  iconSize: (isVertical(context)) ? 24 : 32,
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
                viewModel.onDuplicateSheetToMe(context: context, sheet: sheet);
              },
              iconSize: (isVertical(context)) ? 24 : 32,
              tooltip: "Duplicar",
              icon: Icon(Icons.copy),
            ),
      subtitle: isShowingByCampaign
          ? (appUser == null)
              ? null
              : Text(appUser!.username!)
          : Text(
              homeSheetVM.getWorldName(
                context: context,
                sheet: sheet,
              ),
            ),
      onTap: () {
        viewModel.goToSheet(
          context,
          sheet: sheet,
          username: username,
          isPushing: isShowingByCampaign,
        );
      },
    );
  }
}
