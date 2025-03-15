import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/services/auth_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/sheet_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_sheet.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';

import '../../../domain/models/sheet_model.dart';

class CampaignViewModel extends ChangeNotifier {
  Campaign? campaign;
  String? campaignId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;
  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  int notificationCount = 0;
  TextEditingController nameController = TextEditingController();

  onInitialize() async {
    if (campaignId != null) {
      isLoading = true;
      campaign = await CampaignService.instance.getCampaignById(campaignId!);
      if (campaign != null) {
        nameController.text = campaign!.name ?? "";
      }
      getSheetsByCampaign();
      isLoading = false;
    }
  }

  onSave() async {
    if (campaign != null) {
      campaign!.name = nameController.text;
      CampaignService.instance.saveCampaign(campaign!);
    }
  }

  bool get isOwner {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (campaign != null && campaign!.listIdOwners.contains(uid)) {
      return true;
    }
    return false;
  }

  bool get isOwnerOrInvited {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (campaign != null && (campaign!.listIdOwners.contains(uid)) ||
        campaign!.listIdPlayers.contains(uid)) {
      return true;
    }
    return false;
  }

  bool _isDrawerClosed = true;
  bool get isDrawerClosed => _isDrawerClosed;
  set isDrawerClosed(bool value) {
    if (value != _isDrawerClosed) {
      _isDrawerClosed = value;
      notifyListeners();
    }
  }

  CampaignSubPages _currentPage = CampaignSubPages.sheets;
  CampaignSubPages get currentPage => _currentPage;
  set currentPage(CampaignSubPages value) {
    _currentPage = value;
    notifyListeners();
  }

  Map<Sheet, AppUser> mapSheetOthers = {};

  getSheetsByCampaign({bool isJustOthers = true}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    SheetService sheetService = SheetService();
    AuthService authService = AuthService();

    if (campaignId != null) {
      CampaignService.instance.getStreamCSByCampaign(campaignId!).listen(
        (snapshot) async {
          mapSheetOthers = {};
          for (var doc in snapshot.docs) {
            CampaignSheet campaignSheet = CampaignSheet.fromMap(doc.data());
            if (isJustOthers && campaignSheet.userId == uid) continue;

            Sheet? sheet = await sheetService.getSheetByUser(
              sheetId: campaignSheet.sheetId,
              userId: campaignSheet.userId,
            );

            AppUser? appUser = await authService.getUserInfosById(
              userId: campaignSheet.userId,
            );

            if (sheet != null && appUser != null) {
              mapSheetOthers[sheet] = appUser;
            }
          }
          notifyListeners();
        },
      );
    }
  }
}
