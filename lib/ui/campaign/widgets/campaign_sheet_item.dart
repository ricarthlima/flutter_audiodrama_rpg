import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_user.dart';
import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../../_core/app_colors.dart';
import '../../_core/components/image_dialog.dart';
import '../../_core/dimensions.dart';
import '../../_core/helpers.dart';
import '../../_core/utils/download_json_file.dart';
import '../../home/components/move_sheet_to_campaign_dialog.dart';
import '../../home/view/home_interact.dart';
import '../../home/view/home_view_model.dart';

class CampaignSheetItem extends StatelessWidget {
  final Sheet sheet;
  final String username;
  final bool isShowingByCampaign;
  final AppUser? appUser;
  final Function? onDetach;

  const CampaignSheetItem({
    super.key,
    required this.sheet,
    required this.username,
    this.isShowingByCampaign = false,
    this.appUser,
    this.onDetach,
  });

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        height: 24,
        width: 24,
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
                          border: Border.all(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                  height: 24,
                  width: 24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      sheet.imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
              )
            : Icon(
                Icons.feed,
                size: 24,
              ),
      ),
      title: Text(
        sheet.characterName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
          ],
        ),
      ),
      trailing: PopupMenuButton<_SheetMenuOptions>(
        onSelected: (_SheetMenuOptions value) {
          switch (value) {
            case _SheetMenuOptions.export:
              downloadJsonFile(sheet.toMapWithoutId(),
                  "sheet-${sheet.characterName.toLowerCase().replaceAll(" ", "_")}.json");
              return;
            case _SheetMenuOptions.openInScreen:
              AppRouter().goSheet(
                context: context,
                username: username,
                sheet: sheet,
                isPushing: isShowingByCampaign,
              );
              return;
            case _SheetMenuOptions.moveToCampaign:
              showMoveSheetToCampaignDialog(
                context: context,
                sheet: sheet,
              );
              return;
            case _SheetMenuOptions.duplicate:
              homeViewModel.onDuplicateSheet(sheet: sheet);
              return;
            case _SheetMenuOptions.remove:
              HomeInteract.onRemoveSheet(context: context, sheet: sheet);
              return;
          }
        },
        itemBuilder: (context) {
          return <PopupMenuEntry<_SheetMenuOptions>>[
            PopupMenuItem(
              value: _SheetMenuOptions.export,
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.file_download_outlined),
                  Text("Exportar"),
                ],
              ),
            ),
            PopupMenuItem(
              value: _SheetMenuOptions.openInScreen,
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.arrow_forward),
                  Text("Abrir"),
                ],
              ),
            ),
            if (sheet.ownerId == FirebaseAuth.instance.currentUser!.uid)
              PopupMenuItem(
                value: _SheetMenuOptions.moveToCampaign,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.move_down_rounded),
                    Text("Mover para campanha"),
                  ],
                ),
              ),
            if (sheet.ownerId == FirebaseAuth.instance.currentUser!.uid)
              PopupMenuItem(
                value: _SheetMenuOptions.duplicate,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.copy),
                    Text("Duplicar"),
                  ],
                ),
              ),
            if (sheet.ownerId == FirebaseAuth.instance.currentUser!.uid)
              PopupMenuItem(
                value: _SheetMenuOptions.remove,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.delete,
                      color: AppColors.red,
                    ),
                    Text("Remover"),
                  ],
                ),
              ),
          ];
        },
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

enum _SheetMenuOptions {
  export,
  openInScreen,
  moveToCampaign,
  duplicate,
  remove,
}
