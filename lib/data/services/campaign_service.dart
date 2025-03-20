import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rpg_audiodrama/_core/helpers/generate_access_key.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign.dart';
import 'package:flutter_rpg_audiodrama/domain/models/campaign_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../_core/release_mode.dart';
import '../../_core/utils/supabase_prefs.dart';
import '../../domain/exceptions/general_exceptions.dart';

class CampaignService {
  CampaignService._();
  static final CampaignService _instance = CampaignService._();
  static CampaignService get instance => _instance;

  final _supabase = Supabase.instance.client;

  Future<Campaign> createCampaign({
    required String name,
    required String description,
    DateTime? nextSession,
    XFile? fileImage,
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
    );

    if (fileImage != null) {
      imageBannerUrl = await uploadImage(
        file: fileImage,
        suffix: "bio",
        campaignId: newCampaign.id,
      );
      newCampaign.imageBannerUrl = imageBannerUrl;
    }

    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .doc(newCampaign.id)
        .set(newCampaign.toMap());

    return newCampaign;
  }

  Future<void> updateImage({
    required XFile fileImage,
    required Campaign campaign,
  }) async {
    await removeImage(campaign: campaign, needToFirestore: false);

    String imageBannerUrl = await uploadImage(
      file: fileImage,
      suffix: "bio",
      campaignId: campaign.id,
    );
    campaign.imageBannerUrl = imageBannerUrl;

    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .doc(campaign.id)
        .set(campaign.toMap());
  }

  // Apenas o próprio usuário
  Future<String> uploadImage({
    required XFile file,
    required String suffix,
    required String campaignId,
  }) async {
    String bucket = SupabasePrefs.storageBucketCampaign;

    String extension = file.name.split(".").last;
    String filePath = "public/$campaignId/$suffix-${DateTime.now()}.$extension";

    Uint8List fileBytes = await file.readAsBytes();

    await _supabase.storage.from(bucket).uploadBinary(
          filePath,
          fileBytes,
          fileOptions: FileOptions(upsert: true),
        );

    final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

    return publicUrl;
  }

  // Apenas o próprio usuário
  Future<void> removeImage(
      {required Campaign campaign, bool needToFirestore = true}) async {
    if (campaign.imageBannerUrl != null) {
      String oldImage = campaign.imageBannerUrl!;
      String fileName = oldImage.split("/").last;

      if (needToFirestore) {
        campaign.imageBannerUrl = null;
        await FirebaseFirestore.instance
            .collection("${releaseCollection}campaigns")
            .doc(campaign.id)
            .set(campaign.toMap());
      }

      _supabase.storage
          .from(SupabasePrefs.storageBucketSheet)
          .remove(["bios/$fileName"]);
    }
  }

  Future<void> joinCampaign(String joinCode) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .where("enterCode", isEqualTo: joinCode)
        .get();

    if (query.size > 0) {
      Campaign campaign = Campaign.fromMap(query.docs[0].data());
      campaign.listIdPlayers.add(uid);
      return FirebaseFirestore.instance
          .collection("${releaseCollection}campaigns")
          .doc(campaign.id)
          .set(campaign.toMap());
    }

    throw CampaignCodeNotFoundException();
  }

  Future<Campaign?> getCampaignById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaigns")
        .doc(id)
        .get();

    if (doc.exists) {
      return Campaign.fromMap(doc.data()!);
    }

    throw CampaignIdNotFoundException();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCampaignStreamById(
      String id) {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .doc(id)
        .snapshots();
  }

  Future<void> saveCampaign(Campaign campaign) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .doc(campaign.id)
        .set(campaign.toMap());
  }

  Future<List<Campaign>> getAllCampaigns() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Campaign> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshotOwner = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaigns")
        .where("listIdOwners", arrayContains: uid)
        .get();

    QuerySnapshot<Map<String, dynamic>> snapshotPlayer = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaigns")
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

  getListMyCampaigns() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Campaign> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshotOwner = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaigns")
        .where("listIdOwners", arrayContains: uid)
        .get();

    for (var doc in snapshotOwner.docs) {
      result.add(Campaign.fromMap(doc.data()));
    }

    return result;
  }

  getListInvitedCampaigns() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Campaign> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshotOwner = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaigns")
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
        .collection("${releaseCollection}campaigns")
        .where("listIdOwners", arrayContains: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInvitedCampaignsStream() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("${releaseCollection}campaigns")
        .where("listIdPlayers", arrayContains: uid)
        .snapshots();
  }

  Future<void> saveCampaignSheet({
    required CampaignSheet campaignSheet,
  }) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaign-sheet")
        .doc(campaignSheet.sheetId)
        .set(campaignSheet.toMap());
  }

  Future<void> removeCampaign({required String sheetId}) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}campaign-sheet")
        .doc(sheetId)
        .delete();
  }

  Future<List<CampaignSheet>> getListCampaignSheet() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<CampaignSheet> result = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaign-sheet")
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
        .collection("${releaseCollection}campaign-sheet")
        .where("userId", isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamCSByCampaign(
      String campaignId) {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}campaign-sheet")
        .where("campaignId", isEqualTo: campaignId)
        .snapshots();
  }

  Future<List<String>?> getListPlayersIdsInWorldBySheet(String sheetId) async {
    DocumentSnapshot<Map<String, dynamic>> query = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}campaign-sheet")
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
}
