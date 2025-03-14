import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/auth_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/remove_dialog.dart';

import '../../../data/services/sheet_service.dart';
import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../components/create_sheet_dialog.dart';

class HomeViewModel extends ChangeNotifier {
  Map<String, String>? mapGuestIds;
  final SheetService sheetService = SheetService();

  AppUser currentAppUser = AppUser(
    email: "",
    username: "",
    id: "",
  );

  void onInitialize() async {
    AppUser? appUser = await AuthService().getCurrentUserInfos();
    if (appUser != null) {
      currentAppUser = appUser;
      notifyListeners();
    }
  }

  void goToSheet(
    BuildContext context, {
    required String username,
    required Sheet sheet,
  }) {
    AppRouter().goSheet(context: context, username: username, sheet: sheet);
  }

  Future<void> onCreateSheetClicked(context) async {
    String? resultName = await showCreateSheetDialog(context);
    if (resultName != null) {
      await sheetService.createSheet(resultName);
    }
  }

  Future<void> onRemoveSheet(
      {required BuildContext context, required Sheet sheet}) async {
    bool? isRemoving = await showRemoveSheetDialog(
      context: context,
      name: sheet.characterName,
    );

    if (isRemoving != null && isRemoving) {
      await sheetService.removeSheet(sheet);
    }
  }

  Future<void> onDuplicateSheet({
    required BuildContext context,
    required Sheet sheet,
  }) async {
    await sheetService.duplicateSheet(sheet);
  }

  bool _isDrawerClosed = true;
  bool get isDrawerClosed => _isDrawerClosed;
  set isDrawerClosed(bool value) {
    if (value != _isDrawerClosed) {
      _isDrawerClosed = value;
      notifyListeners();
    }
  }

  HomeSubPages _currentPage = HomeSubPages.sheets;
  HomeSubPages get currentPage => _currentPage;
  set currentPage(HomeSubPages value) {
    _currentPage = value;
    notifyListeners();
  }
}

enum HomeSubPages {
  sheets,
  campaigns,
  profile,
}
