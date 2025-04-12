import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/utils/download_json_file.dart';
import 'package:flutter_rpg_audiodrama/ui/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../../_core/dimensions.dart';
import '../view/sheet_view_model.dart';

import 'package:badges/badges.dart' as badges;

AppBar getSheetAppBar(BuildContext context) {
  final sheetVM = Provider.of<SheetViewModel>(context);

  if (sheetVM.isLoading ||
      (sheetVM.isAuthorized != null && !sheetVM.isAuthorized!) ||
      !sheetVM.isFoundSheet) {
    return AppBar(
      toolbarHeight: 64,
      actions: [Container()],
    );
  }

  return AppBar(
    toolbarHeight: 64,
    leading: IconButton(
      tooltip: "Voltar",
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          AppRouter().goHome(context: context);
        }
      },
      icon: Icon(Icons.arrow_back),
    ),
    backgroundColor: sheetVM.imageUrl != null
        ? Theme.of(context).scaffoldBackgroundColor.withAlpha(75)
        : null,
    actions: [
      IconButton(
        onPressed: () {
          _downloadSheetJSON(sheetVM);
        },
        tooltip: "Exportar JSON",
        icon: Icon(Icons.file_upload_outlined),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("•"),
      ),
      if (sheetVM.ownerId == FirebaseAuth.instance.currentUser!.uid &&
          !isVertical(context) &&
          sheetVM.listSheets.isNotEmpty)
        DropdownButton<Sheet>(
          value: sheetVM.listSheets.where((e) => e.id == sheetVM.id).first,
          items: sheetVM.listSheets
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.characterName),
                ),
              )
              .toList(),
          onChanged: (Sheet? sheet) {
            if (sheet != null) {
              AppRouter().goSheet(
                context: context,
                username: sheetVM.username,
                sheet: sheet,
              );
            }
          },
        ),
      if (sheetVM.ownerId == FirebaseAuth.instance.currentUser!.uid)
        Row(
          children: [
            Visibility(
              visible: !isVertical(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("•"),
              ),
            ),
            Visibility(
              visible: sheetVM.isEditing,
              child: Text("Saia da edição para salvar"),
            ),
            Visibility(
              visible: sheetVM.isEditing,
              child: SizedBox(width: 8),
            ),
            Icon(Icons.edit),
            Switch(
              value: sheetVM.isEditing,
              onChanged: (value) {
                sheetVM.toggleEditMode();
              },
            ),
          ],
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text("•"),
      ),
      IconButton(
        onPressed: () {
          showSettingsDialog(context);
        },
        icon: Icon(Icons.settings),
      ),
      if (!isVertical(context))
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("•"),
        ),
      if (!isVertical(context))
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
              sheetVM.notificationCount = 0;
            },
            icon: badges.Badge(
              showBadge: sheetVM.notificationCount >
                  0, // Esconde se não houver notificações
              badgeContent: Text(
                sheetVM.notificationCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              position: badges.BadgePosition.topEnd(
                top: -10,
                end: -12,
              ), // Ajusta posição
              child: Icon(Icons.chat),
            ),
          ),
        ),
      SizedBox(width: 16),
    ],
  );
}

_downloadSheetJSON(SheetViewModel sheetVM) async {
  Sheet sheet = await sheetVM.saveChanges();
  downloadJsonFile(
    sheet.toMapWithoutId(),
    "sheet-${sheet.characterName.toLowerCase().replaceAll(" ", "_")}.json",
  );
}
