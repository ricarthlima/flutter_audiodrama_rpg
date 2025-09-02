// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/preferences/local_data_manager.dart';
import 'package:flutter_rpg_audiodrama/data/services/auth_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/chat_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/sheet_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_sheet.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/sheet_model.dart';

class CampaignViewModel extends ChangeNotifier {
  bool _hasInteracted = false;
  bool get hasInteracted => _hasInteracted;
  set hasInteracted(bool value) {
    _hasInteracted = value;
    notifyListeners();
  }

  void hasInteractedDisable() {
    _hasInteracted = false;
    campaign = null;
  }

  Campaign? campaign;
  // String? campaignId;

  StreamSubscription? sheetsSub;

  Future<void> forceUpdateCampaign(Campaign campaign) async {
    isLoading = true;

    if (sheetsSub != null) {
      await sheetsSub!.cancel();
    }

    this.campaign = campaign;
    // campaignId = campaign.id;
    nameController.text = campaign.name ?? "";
    descController.text = campaign.description ?? "";
    notificationCount = 0;

    await _verifyNewAchievement();
    await getSheetsByCampaign();

    isLoading = false;
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;
  set isEditing(bool value) {
    _isEditing = value;
    if (value == false) {
      onSave();
    }
    notifyListeners();
  }

  int notificationCount = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  Future<void> onSave() async {
    if (campaign != null) {
      campaign!.name = nameController.text;
      campaign!.description = descController.text;
      CampaignService.instance.saveCampaign(campaign!);
      notifyListeners();
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

  CampaignTabs? _currentTab;
  CampaignTabs? get currentTab => _currentTab;
  set currentTab(CampaignTabs? value) {
    _currentTab = value;
    notifyListeners();
  }

  List<SheetAppUser> listSheetAppUser = [];

  Future<void> getSheetsByCampaign({bool isJustOthers = true}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    SheetService sheetService = SheetService();
    AuthService authService = AuthService();

    if (campaign != null) {
      sheetsSub = CampaignService.instance
          .getStreamCSByCampaign(campaign!.id)
          .listen((snapshot) async {
            listSheetAppUser = [];

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
                listSheetAppUser.add(
                  SheetAppUser(sheet: sheet, appUser: appUser),
                );
              }
            }
            notifyListeners();
          });
    }
  }

  Future<void> onUpdateImage(XFile imageBytes) async {
    if (campaign != null) {
      await CampaignService.instance.updateImage(
        fileImage: imageBytes,
        campaign: campaign!,
      );
      notifyListeners();
    }
  }

  Future<void> onRemoveImage() async {
    if (campaign != null) {
      await CampaignService.instance.removeImage(campaign: campaign!);
      campaign!.imageBannerUrl = null;
      notifyListeners();
    }
  }

  Future<void> onCreateAchievement({
    String? idd,
    required String name,
    required String description,
    required bool isHide,
    required bool isHideDescription,
    required bool isImageHided,
    XFile? image,
  }) async {
    String id = Uuid().v7();

    if (idd != null) {
      id = idd;
    }

    String? urlImage;

    if (image != null) {
      urlImage = await CampaignService.instance.uploadImage(
        file: image,
        suffix: "achievement-$id",
        campaignId: campaign!.id,
      );
    } else {
      if (idd != null) {
        urlImage = campaign!.listAchievements
            .where((e) => e.id == idd)
            .first
            .imageUrl;
      }
    }

    CampaignAchievement achievement = CampaignAchievement(
      id: id,
      imageUrl: urlImage,
      title: name,
      description: description,
      isHided: isHide,
      isDescriptionHided: isHideDescription,
      isImageHided: isImageHided,
      listUsers: [],
    );

    if (campaign!.listAchievements.where((e) => e.id == idd).isNotEmpty) {
      achievement.listUsers = campaign!.listAchievements
          .where((e) => e.id == idd)
          .first
          .listUsers;

      int index = campaign!.listAchievements.indexWhere((e) => e.id == idd);
      campaign!.listAchievements[index] = achievement;
    } else {
      campaign!.listAchievements.add(achievement);
    }

    await onSave();
  }

  Future<void> onRemoveAchievement(CampaignAchievement achievement) async {
    campaign!.listAchievements.remove(achievement);
    await onSave();
  }

  Future<void> updateAchievement(CampaignAchievement achievement) async {
    int index = campaign!.listAchievements.indexWhere(
      (e) => e.id == achievement.id,
    );
    campaign!.listAchievements[index] = achievement;
    await onSave();
  }

  List<CampaignAchievement> listNewAchievements = [];

  Future<void> _verifyNewAchievement() async {
    if (!isOwner) {
      List<String> listMyAch = await LocalDataManager.instance
          .getAchievementsListIds();

      List<CampaignAchievement> listNewAch = List.from(
        campaign!.listAchievements.where(
          (e) => e.listUsers.contains(FirebaseAuth.instance.currentUser!.uid),
        ),
      );

      listNewAch.removeWhere((e) => listMyAch.contains(e.id));

      if (listNewAch.isNotEmpty) {
        listNewAchievements = listNewAch;
        notifyListeners();
      }
    }
  }

  void hasAchievementShowed(CampaignAchievement achievement) async {
    await LocalDataManager.instance.addAchievement(achievement.id);
    listNewAchievements.removeWhere((e) => e.id == achievement.id);
    notifyListeners();
  }

  void unlockToAllUsers(CampaignAchievement achievement) async {
    await updateAchievement(
      achievement.copyWith(listUsers: campaign!.listIdPlayers),
    );
  }

  List<SheetAppUser> listOpenSheet = [];

  void openSheetInCampaign(SheetAppUser sheetAppUser) {
    if (listOpenSheet
        .where((e) => e.sheet.id == sheetAppUser.sheet.id)
        .isEmpty) {
      listOpenSheet.add(sheetAppUser);
      notifyListeners();
    }
  }

  void closeSheetInCampaign(Sheet sheet) {
    listOpenSheet.removeWhere((element) => element.sheet.id == sheet.id);
    notifyListeners();
  }

  void activatePresence() async {
    ChatService.instance.addUserToCampaign(
      userId: FirebaseAuth.instance.currentUser!.uid,
      campaignId: campaign!.id,
    );
  }

  bool _isChatFirstTime = true;
  bool get isChatFirstTime => _isChatFirstTime;
  set isChatFirstTime(bool value) {
    _isChatFirstTime = value;
    notifyListeners();
  }

  int countChatMessages = 0;

  Future<void> deleteCampaign() async {
    CampaignService.instance.deleteCampaign(campaign!.id);
  }

  Future<void> exitCampaign() async {
    //TODO: Sair da campanha
  }

  void toggleActiveWork(String workId) {
    if (campaign!.campaignSheetSettings.listActiveWorkIds.contains(workId)) {
      campaign!.campaignSheetSettings.listActiveWorkIds.remove(workId);
    } else {
      campaign!.campaignSheetSettings.listActiveWorkIds.add(workId);
    }
    notifyListeners();
    onSave();
  }
}

class SheetAppUser {
  Sheet sheet;
  AppUser appUser;

  SheetAppUser({required this.sheet, required this.appUser});
}
