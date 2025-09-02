import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../../_core/dimensions.dart';
import '../providers/sheet_view_model.dart';

AppBar getSheetAppBar(BuildContext context) {
  final sheetVM = Provider.of<SheetViewModel>(context);

  if (sheetVM.isLoading ||
      (sheetVM.isAuthorized != null && !sheetVM.isAuthorized!) ||
      !sheetVM.isFoundSheet) {
    return AppBar(toolbarHeight: 64, actions: [Container()]);
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
    backgroundColor: sheetVM.sheet!.imageUrl != null
        ? Theme.of(context).scaffoldBackgroundColor.withAlpha(75)
        : null,
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("•"),
      ),
      if (sheetVM.sheet!.ownerId == FirebaseAuth.instance.currentUser!.uid &&
          !isVertical(context) &&
          sheetVM.listSheets.isNotEmpty)
        DropdownButton<Sheet>(
          value: sheetVM.listSheets.where((e) => e.id == sheetVM.id).first,
          items: sheetVM.listSheets
              .map(
                (e) => DropdownMenuItem(value: e, child: Text(e.characterName)),
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
    ],
  );
}
