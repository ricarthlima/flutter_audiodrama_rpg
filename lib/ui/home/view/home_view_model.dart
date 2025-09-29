import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/campaign_service.dart';
import '../../../data/services/sheet_service.dart';
import '../../../domain/models/campaign_sheet.dart';
import '../../../domain/models/sheet_model.dart';
import '../utils/home_tabs.dart';

class HomeViewModel extends ChangeNotifier {
  final SheetService sheetService = SheetService();

  bool _isDrawerClosed = true;
  bool get isDrawerClosed => _isDrawerClosed;
  set isDrawerClosed(bool value) {
    if (value != _isDrawerClosed) {
      _isDrawerClosed = value;
      notifyListeners();
    }
  }

  HomeTabs _currentPage = HomeTabs.sheets;
  HomeTabs get currentPage => _currentPage;
  set currentPage(HomeTabs value) {
    _currentPage = value;
    notifyListeners();
  }

  Future<void> onCreateSheetClicked({
    required String name,
    String? campaignId,
  }) async {
    await sheetService.createSheet(name, campaignId: campaignId);
  }

  Future<void> onRemoveSheet({required Sheet sheet}) async {
    await sheetService.removeSheet(sheet);
  }

  Future<void> onDuplicateSheet({required Sheet sheet}) async {
    await sheetService.duplicateSheet(sheet);
  }

  Future<void> onDuplicateSheetToMe({
    required Sheet sheet,
    String? campaignId,
  }) async {
    await sheetService.duplicateSheetToMe(sheet, campaignId);
  }

  Future<void> saveCampaignSheet({
    required String campaignId,
    required String sheetId,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await CampaignService.instance.saveCampaignSheet(
      campaignSheet: CampaignSheet(
        userId: uid,
        campaignId: campaignId,
        sheetId: sheetId,
      ),
    );
  }

  Future<void> removeSheetFromCampaign(String sheetId) {
    return CampaignService.instance.removeCampaign(sheetId: sheetId);
  }

  Future<void> createSheetByMap(Map<String, dynamic> map) async {
    Sheet sheet = Sheet.fromMap(map);
    sheet.id = Uuid().v1();

    await sheetService.saveSheet(sheet);
  }
}
