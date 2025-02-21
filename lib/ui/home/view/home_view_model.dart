import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
}
