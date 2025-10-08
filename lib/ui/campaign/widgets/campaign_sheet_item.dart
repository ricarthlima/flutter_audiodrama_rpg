import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/modules.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/view/campaign_view_model.dart';
import '../../_core/web/download_json/download_json.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_user.dart';
import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../../_core/app_colors.dart';
import '../../_core/components/image_dialog.dart';
import '../../_core/dimensions.dart';
import '../../_core/helpers.dart';
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
    final homeVM = Provider.of<HomeViewModel>(context);
    final campaignVM = context.watch<CampaignProvider>();

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        child: Draggable<Sheet>(
          data: sheet,
          feedback: Material(
            child: SizedBox(
              width: 72,
              height: 72,
              child: (sheet.listTokens.isNotEmpty)
                  ? Image.network(sheet.listTokens[sheet.indexToken])
                  : (sheet.imageUrl != null)
                  ? Image.network(sheet.imageUrl!)
                  : Icon(Icons.person),
            ),
          ),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        sheet.imageUrl!,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                )
              : Icon(Icons.feed, size: 24),
        ),
      ),
      title: Text(
        sheet.characterName,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (campaignVM.isModuleActive(Module.combat.id))
            IconButton(
              onPressed: () {
                campaignVM.rollInitiative(sheet: sheet, isVisible: true);
              },
              onLongPress: () {
                campaignVM.rollInitiative(sheet: sheet, isVisible: false);
              },
              tooltip: "Rolar Iniciativa",
              icon: Image.asset("assets/images/d20.png", color: AppColors.red),
            ),
          PopupMenuButton<_SheetMenuOptions>(
            onSelected: (_SheetMenuOptions value) {
              switch (value) {
                case _SheetMenuOptions.export:
                  downloadJsonFile(
                    sheet.toMapWithoutId(),
                    "sheet-${sheet.characterName.toLowerCase().replaceAll(" ", "_")}.json",
                  );
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
                  showMoveSheetToCampaignDialog(context: context, sheet: sheet);
                  return;
                case _SheetMenuOptions.duplicate:
                  homeVM.onDuplicateSheet(sheet: sheet);
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
                    children: [Icon(Icons.arrow_forward), Text("Abrir")],
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
                      children: [Icon(Icons.copy), Text("Duplicar")],
                    ),
                  ),
                if (sheet.ownerId == FirebaseAuth.instance.currentUser!.uid)
                  PopupMenuItem(
                    value: _SheetMenuOptions.remove,
                    child: Row(
                      spacing: 8,
                      children: [
                        Icon(Icons.delete, color: AppColors.red),
                        Text("Remover"),
                      ],
                    ),
                  ),
              ];
            },
          ),
        ],
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
