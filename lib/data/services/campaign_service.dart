import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_turn_order.dart';
import '../../domain/models/campaign_sheet_settings.dart';
import '../../ui/campaign/utils/campaign_scenes.dart';
import '../../_core/helpers/generate_access_key.dart';
import '../../_core/helpers/release_collections.dart';
import '../../_core/providers/audio_provider.dart';
import '../../domain/models/campaign.dart';
import '../../domain/models/campaign_sheet.dart';
import '../../domain/models/campaign_vm_model.dart';
import 'package:uuid/uuid.dart';

import '../../domain/exceptions/general_exceptions.dart';

class CampaignService {
  CampaignService._();
  static final CampaignService _instance = CampaignService._();
  static CampaignService get instance => _instance;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final storageRef = FirebaseStorage.instance.ref();

  Future<Campaign> createCampaign({
    required String name,
    required String description,
    DateTime? nextSession,
    Uint8List? fileImage,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String? imageBannerUrl;

    // TODO: Estou ignorando colisão
    String enterCode = generateAccessKey();

    Campaign newCampaign = Campaign(
      id: Uuid().v4(),
      listIdOwners: [uid],
      listIdPlayers: [],
      enterCode: enterCode,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      name: name,
      description: description,
      imageBannerUrl: imageBannerUrl,
      nextSession: nextSession,
      listAchievements: [],
      visualData: CampaignVisualDataModel.empty(),
      audioCampaign: AudioCampaign(),
      campaignSheetSettings: CampaignSheetSettings(
        listActiveWorkIds: [],
        listActiveModuleIds: [],
        activePublicRolls: false,
      ),
      campaignScenes: CampaignScenes.novel,
      activeBattleMapId: null,
      listBattleMaps: [],
      campaignTurnOrder: CampaignTurnOrder(
        isTurnActive: false,
        turn: 0,
        sheetTurn: 0,
        listSheetOrders: [],
      ),
      activeSceneType: CampaignScenes.novel,
    );

    if (fileImage != null) {
      imageBannerUrl = await uploadBioImage(
        imageBytes: fileImage,
        campaignId: newCampaign.id,
      );
      newCampaign.imageBannerUrl = imageBannerUrl;
    }

    await FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .doc(newCampaign.id)
        .set(newCampaign.toMap());

    return newCampaign;
  }

  // Apenas o próprio usuário
  Future<String> uploadBioImage({
    required Uint8List imageBytes,
    required String campaignId,
  }) async {
    String filePath = "users/$uid/campaigns/$campaignId/bio.png";
    final fileRef = storageRef.child(filePath);

    await fileRef.putData(imageBytes);

    return await fileRef.getDownloadURL();
  }

  // Apenas o próprio usuário
  Future<void> removeBioImage({required String campaignId}) async {
    String filePath = "/campaigns/$campaignId/bio.png";
    final fileRef = storageRef.child(filePath);
    return fileRef.delete();
  }

  Future<String> uploadAchievementImage({
    required Uint8List imageBytes,
    required String campaignId,
    required String achievementId,
  }) async {
    String filePath =
        "users/$uid/campaigns/$campaignId/achievement-$achievementId.png";
    final fileRef = storageRef.child(filePath);

    await fileRef.putData(imageBytes);

    return await fileRef.getDownloadURL();
  }

  Future<void> joinCampaign(String joinCode) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .where("enterCode", isEqualTo: joinCode)
        .get();

    if (query.size > 0) {
      Campaign campaign = Campaign.fromMap(query.docs[0].data());
      campaign.listIdPlayers.add(uid);
      return FirebaseFirestore.instance
          .collection("${rc}campaigns")
          .doc(campaign.id)
          .set(campaign.toMap());
    }

    throw CampaignCodeNotFoundException();
  }

  Future<Campaign?> getCampaignById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${rc}campaigns")
        .doc(id)
        .get();

    if (doc.exists) {
      return Campaign.fromMap(doc.data()!);
    }

    throw CampaignIdNotFoundException();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCampaignStreamById(
    String id,
  ) {
    return FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .doc(id)
        .snapshots();
  }

  Future<void> saveCampaign(Campaign campaign) async {
    await FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .doc(campaign.id)
        .set(campaign.toMap());
  }

  Future<List<Campaign>> getAllCampaigns() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Campaign> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshotOwner = await FirebaseFirestore
        .instance
        .collection("${rc}campaigns")
        .where("listIdOwners", arrayContains: uid)
        .get();

    QuerySnapshot<Map<String, dynamic>> snapshotPlayer = await FirebaseFirestore
        .instance
        .collection("${rc}campaigns")
        .where("listIdPlayers", arrayContains: uid)
        .get();

    for (var doc in snapshotOwner.docs) {
      result.add(Campaign.fromMap(doc.data()));
    }

    for (var doc in snapshotPlayer.docs) {
      result.add(Campaign.fromMap(doc.data()));
    }

    return result;
  }

  Future<List<Campaign>> getListMyCampaigns() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Campaign> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshotOwner = await FirebaseFirestore
        .instance
        .collection("${rc}campaigns")
        .where("listIdOwners", arrayContains: uid)
        .get();

    for (var doc in snapshotOwner.docs) {
      result.add(Campaign.fromMap(doc.data()));
    }

    return result;
  }

  Future<List<Campaign>> getListInvitedCampaigns() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Campaign> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshotOwner = await FirebaseFirestore
        .instance
        .collection("${rc}campaigns")
        .where("listIdPlayers", arrayContains: uid)
        .get();

    for (var doc in snapshotOwner.docs) {
      result.add(Campaign.fromMap(doc.data()));
    }

    return result;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyCampaignsStream() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .where("listIdOwners", arrayContains: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInvitedCampaignsStream() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .where("listIdPlayers", arrayContains: uid)
        .snapshots();
  }

  Future<void> saveCampaignSheet({required CampaignSheet campaignSheet}) async {
    await FirebaseFirestore.instance
        .collection("${rc}campaign-sheet")
        .doc(campaignSheet.sheetId)
        .set(campaignSheet.toMap());
  }

  Future<void> removeCampaign({required String sheetId}) async {
    await FirebaseFirestore.instance
        .collection("${rc}campaign-sheet")
        .doc(sheetId)
        .delete();
  }

  Future<List<CampaignSheet>> getListCampaignSheet() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<CampaignSheet> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("${rc}campaign-sheet")
        .where("userId", isEqualTo: uid)
        .get();

    for (var doc in snapshot.docs) {
      result.add(CampaignSheet.fromMap(doc.data()));
    }

    return result;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCampaignSheetStream() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("${rc}campaign-sheet")
        .where("userId", isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamCSByCampaign(
    String campaignId,
  ) {
    return FirebaseFirestore.instance
        .collection("${rc}campaign-sheet")
        .where("campaignId", isEqualTo: campaignId)
        .snapshots();
  }

  Future<List<String>?> getListPlayersIdsInWorldBySheet(String sheetId) async {
    DocumentSnapshot<Map<String, dynamic>> query = await FirebaseFirestore
        .instance
        .collection("${rc}campaign-sheet")
        .doc(sheetId)
        .get();

    if (query.exists) {
      CampaignSheet campaignSheet = CampaignSheet.fromMap(query.data()!);
      Campaign? campaign = await getCampaignById(campaignSheet.campaignId);
      if (campaign != null) {
        return campaign.listIdOwners;
      }
    }
    return null;
  }

  Future<void> deleteCampaign(String campaignId) async {
    // TODO: Isso COM CERTEZA devia ser Firebase Function

    await FirebaseFirestore.instance
        .collection("${rc}campaigns")
        .doc(campaignId)
        .delete();

    final queryCS = await FirebaseFirestore.instance
        .collection("${rc}campaign-sheet")
        .where('campaignId', isEqualTo: campaignId)
        .get();

    for (var doc in queryCS.docs) {
      CampaignSheet cs = CampaignSheet.fromMap(doc.data());
      await FirebaseFirestore.instance
          .collection("${rc}campaign-sheet")
          .doc(cs.sheetId)
          .delete();
    }
  }

  Future<String> uploadBattleMapImage({
    required Uint8List image,
    required String campaignId,
    required String id,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String filePath = "users/$uid/campaigns/$campaignId/battle-maps/$id.png";

    final fileRef = storageRef.child(filePath);

    await fileRef.putData(image);
    return await fileRef.getDownloadURL();
  }

  Future<void> removeBattleMap({
    required String campaignId,
    required String battleMapId,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String filePath =
        "users/$uid/campaigns/$campaignId/battle-maps/$battleMapId.png";
    final fileRef = storageRef.child(filePath);
    return await fileRef.delete();
  }
}
