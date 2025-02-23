import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/remove_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../../_core/private/auth_user.dart';
import '../../../data/services/sheet_service.dart';
import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../components/create_sheet_dialog.dart';

class HomeViewModel extends ChangeNotifier {
  Map<String, String>? mapGuestIds;
  final SheetService sheetService = SheetService();

  void loadGuestIds() async {
    if (FirebaseAuth.instance.currentUser!.uid == SecretAuthIds.ricarthId) {
      mapGuestIds = SecretAuthIds.listIds;
      notifyListeners();
    }
  }

  void goToSheet(
    BuildContext context, {
    required String userId,
    required Sheet sheet,
  }) {
    GoRouter.of(context).go(
      "${AppRouter.sheet}/${sheet.id}",
      extra: userId,
    );
  }

  onCreateSheetClicked(context) async {
    String? resultName = await showCreateSheetDialog(context);
    if (resultName != null) {
      sheetService.createSheet(resultName);
    }
  }

  onRemoveSheet({required BuildContext context, required Sheet sheet}) async {
    bool? isRemoving = await showRemoveSheetDialog(
      context: context,
      name: sheet.characterName,
    );

    if (isRemoving != null && isRemoving) {
      await sheetService.removeSheet(sheet);
    }
  }
}
