// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/helpers/important_actions.dart';
import 'package:flutter_rpg_audiodrama/data/preferences/local_data_manager.dart';
import 'package:flutter_rpg_audiodrama/data/services/auth_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/campaign_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/chat_service.dart';
import 'package:flutter_rpg_audiodrama/data/services/sheet_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_achievement.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_sheet.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_turn_order.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_scenes.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/sheet_model.dart';
import '../../_core/helpers/image_size_from_bytes.dart';
import '../../campaign_battle_map/models/battle_map.dart';

class CampaignProvider extends ChangeNotifier {
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

  void loadingStart() {
    isLoading = true;
    notifyListeners();
  }

  void loadingStop() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> startCampaign(Campaign campaign) async {
    loadingStart();

    removeTrash();
    this.campaign = campaign;
    nameController.text = campaign.name ?? "";
    descController.text = campaign.description ?? "";
    notificationCount = 0;

    await _verifyNewAchievement();
    await getSheetsByCampaign();
    loadingStop();
  }

  Future<void> updateCampaign(Campaign campaign) async {
    isLoading = true;
    notifyListeners();

    if (this.campaign != null && this.campaign!.id != campaign.id) {
      removeTrash();
    }

    this.campaign = campaign;

    nameController.text = campaign.name ?? "";
    descController.text = campaign.description ?? "";
    notificationCount = 0;

    await _verifyNewAchievement();
    await getSheetsByCampaign();

    isLoading = false;
    notifyListeners();
  }

  void removeTrash() async {
    listOpenSheet = [];
    if (sheetsSub != null) {
      await sheetsSub!.cancel();
    }
  }

  @override
  void dispose() {
    removeTrash();
    super.dispose();
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
    notifyListeners();
    if (campaign != null) {
      campaign!.name = nameController.text;
      campaign!.description = descController.text;
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

  CampaignTabs? _currentTab;
  CampaignTabs? get currentTab => _currentTab;
  set currentTab(CampaignTabs? value) {
    _currentTab = value;
    notifyListeners();
  }

  List<SheetAppUser> listSheetAppUser = [];
  List<AppUser> listUsers = [];

  Future<void> getSheetsByCampaign({bool isJustOthers = true}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    SheetService sheetService = SheetService();
    AuthService authService = AuthService();

    if (campaign != null) {
      sheetsSub = CampaignService.instance
          .getStreamCSByCampaign(campaign!.id)
          .listen((snapshot) async {
            listSheetAppUser = [];
            listUsers = [];

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

                if (!listUsers.contains(appUser)) {
                  listUsers.add(appUser);
                }
              }
            }

            notifyListeners();
          });
    }
  }

  Future<void> onUpdateImage(Uint8List imageBytes) async {
    if (campaign != null) {
      String urlDownload = await CampaignService.instance.uploadBioImage(
        imageBytes: imageBytes,
        campaignId: campaign!.id,
      );
      campaign!.imageBannerUrl = urlDownload;
      notifyListeners();
      onSave();
    }
  }

  Future<void> onRemoveImage() async {
    if (campaign != null) {
      await CampaignService.instance.removeBioImage(campaignId: campaign!.id);
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
    Uint8List? image,
  }) async {
    String id = Uuid().v7();

    if (idd != null) {
      id = idd;
    }

    String? urlImage;

    if (image != null) {
      urlImage = await CampaignService.instance.uploadAchievementImage(
        imageBytes: image,
        campaignId: campaign!.id,
        achievementId: id,
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

  void toggleModuleWork(String workId) {
    if (campaign!.campaignSheetSettings.listActiveModuleIds.contains(workId)) {
      campaign!.campaignSheetSettings.listActiveModuleIds.remove(workId);
    } else {
      campaign!.campaignSheetSettings.listActiveModuleIds.add(workId);
    }
    notifyListeners();
    onSave();
  }

  CampaignScenes get campaignScene => campaign!.campaignScenes;
  set campaignScene(CampaignScenes value) {
    campaign!.campaignScenes = value;
    notifyListeners();
    onSave();
  }

  Future<void> activeGlobalBattleMap(BattleMap battleMap) async {
    campaign!.activeBattleMapId = battleMap.id;
    notifyListeners();
    campaign!.activeSceneType = CampaignScenes.grid;
    onSave();
  }

  void deactivateGlobalBattleMap() {
    campaign!.activeBattleMapId = null;
    notifyListeners();
    campaign!.activeSceneType = CampaignScenes.novel;
    onSave();
  }

  Future<void> removeBattleMap(BattleMap battleMap) async {
    if (campaign!.activeBattleMapId == battleMap.id) {
      campaign!.activeBattleMapId = null;
    }
    campaign!.listBattleMaps.removeWhere((e) => e.id == battleMap.id);
    notifyListeners();
    await CampaignService.instance.removeBattleMap(
      campaignId: campaign!.id,
      battleMapId: battleMap.id,
    );
    onSave();
  }

  Future<void> upinsertBattleMap({
    required String id,
    required String name,
    required int columns,
    required int rows,
    required Uint8List image,
    required String? ambience,
    required String? music,
  }) async {
    BattleMap battleMap = BattleMap(
      id: id,
      name: name,
      rows: rows,
      columns: columns,
      listTokens: [],
      ambienceId: ambience,
      musicId: music,
      imageUrl: "",
      imageSize: await imageSizeFromBytes(image),
      gridColor: Colors.white,
      gridOpacity: 1,
    );

    String imageUrl = await CampaignService.instance.uploadBattleMapImage(
      image: image,
      campaignId: campaign!.id,
      id: id,
    );

    battleMap.imageUrl = imageUrl;

    int index = campaign!.listBattleMaps.indexWhere((e) => e.id == id);
    if (index == -1) {
      campaign!.listBattleMaps.add(battleMap);
    } else {
      campaign!.listBattleMaps[index] = campaign!.listBattleMaps[index]
          .copyWith(
            name: name,
            rows: rows,
            columns: columns,
            ambienceId: ambience,
            musicId: music,
            imageUrl: imageUrl,
          );
    }

    onSave();
  }

  void addSheetTurn() {
    campaign!.campaignTurnOrder.sheetTurn++;
    _updateTurnBySheetTurn();
    onSave();
  }

  void removeSheetTurn() {
    campaign!.campaignTurnOrder.sheetTurn--;
    _updateTurnBySheetTurn();
    onSave();
  }

  void _updateTurnBySheetTurn() {
    if (campaign!.campaignTurnOrder.sheetTurn == -1) {
      campaign!.campaignTurnOrder.turn--;
    } else if (campaign!.campaignTurnOrder.sheetTurn ==
        campaign!.campaignTurnOrder.listSheetOrders.length) {
      campaign!.campaignTurnOrder.turn++;
    }

    campaign!.campaignTurnOrder.sheetTurn =
        campaign!.campaignTurnOrder.sheetTurn %
        campaign!.campaignTurnOrder.listSheetOrders.length;

    notifyListeners();
  }

  void addTurn() {
    campaign!.campaignTurnOrder.turn++;
    notifyListeners();
    onSave();
  }

  void removeTurn() {
    campaign!.campaignTurnOrder.turn--;
    notifyListeners();
    onSave();
  }

  void rollInitiative({
    required Sheet sheet,
    required bool isVisible,
    int? rollValue,
  }) {
    int value = 1;

    if (rollValue != null) {
      value = rollValue;
    } else {
      int indexActionValue = sheet.listActionValue.indexWhere(
        (e) => e.actionId == ImportantActions.resistirReflexos,
      );

      if (indexActionValue != -1) {
        value = sheet.listActionValue[indexActionValue].value;
      }

      int dice1 = Random().nextInt(19) + 1;
      int dice2 = Random().nextInt(19) + 1;
      int dice3 = Random().nextInt(19) + 1;

      switch (value) {
        case 0:
          {
            value = min(min(dice1, dice2), dice3);
          }
        case 1:
          {
            value = min(dice1, dice2);
          }
        case 2:
          {
            value = dice1;
          }
        case 3:
          {
            value = max(dice1, dice2);
          }
        case 4:
          {
            value = max(max(dice1, dice2), dice3);
          }
      }
    }

    final sheetTurn = SheetTurnOrder(
      sheetId: sheet.id,
      orderValue: value,
      isVisible: isVisible,
    );

    int index = campaign!.campaignTurnOrder.listSheetOrders.indexWhere(
      (e) => e.sheetId == sheet.id,
    );

    if (index == -1) {
      campaign!.campaignTurnOrder.listSheetOrders.add(sheetTurn);
    } else {
      campaign!.campaignTurnOrder.listSheetOrders[index] = sheetTurn;
    }

    sortTurn();
    onSave();
  }

  void toggleTurnVisibility({required String sheetId}) {
    int index = campaign!.campaignTurnOrder.listSheetOrders.indexWhere(
      (e) => e.sheetId == sheetId,
    );

    if (index != -1) {
      campaign!.campaignTurnOrder.listSheetOrders[index].isVisible =
          !campaign!.campaignTurnOrder.listSheetOrders[index].isVisible;
    }

    onSave();
  }

  void changeTurnValue({required String sheetId, required int orderValue}) {
    int index = campaign!.campaignTurnOrder.listSheetOrders.indexWhere(
      (e) => e.sheetId == sheetId,
    );

    if (index != -1) {
      campaign!.campaignTurnOrder.listSheetOrders[index].orderValue =
          orderValue;
    }

    sortTurn();
    onSave();
  }

  void removeFromTurn(String sheetId) {
    campaign!.campaignTurnOrder.listSheetOrders.removeWhere(
      (e) => e.sheetId == sheetId,
    );

    sortTurn();
    onSave();
  }

  void sortTurn() {
    campaign!.campaignTurnOrder.listSheetOrders.sort((a, b) {
      return b.orderValue.compareTo(a.orderValue);
    });
    notifyListeners();
  }

  bool isModuleActive(String id) {
    return campaign!.campaignSheetSettings.listActiveModuleIds.contains(id);
  }

  bool _isPreviewVisible = false;
  bool get isPreviewVisible => _isPreviewVisible;
  set isPreviewVisible(bool value) {
    _isPreviewVisible = value;
    notifyListeners();
  }

  void setSceneType(CampaignScenes type) {
    campaign!.activeSceneType = type;
    onSave();
  }
}

class SheetAppUser {
  Sheet sheet;
  AppUser appUser;

  SheetAppUser({required this.sheet, required this.appUser});
}
