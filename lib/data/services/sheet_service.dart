import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../modules.dart';
import '../../domain/models/sheet_custom_count.dart';
import '../../_core/helpers/release_collections.dart';
import 'campaign_service.dart';
import '../../domain/exceptions/sheet_service_exceptions.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/campaign_sheet.dart';
import '../../domain/models/sheet_model.dart';
import 'package:uuid/uuid.dart';

class SheetService {
  final storageRef = FirebaseStorage.instance.ref();

  Future<List<String>> getListUsers() async {
    QuerySnapshot<Map<String, dynamic>> listUsersSnapshot =
        await FirebaseFirestore.instance.collection("${rc}users").get();

    final listUsers = listUsersSnapshot.docs;
    return listUsers.map((e) => e.id).toList();
  }

  Future<AppUser> getUserByUsername(String username) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection("${rc}users")
        .where("username", isEqualTo: username)
        .get();

    if (querySnapshot.size >= 1) {
      AppUser user = AppUser.fromMap(querySnapshot.docs.first.data());
      user.id = querySnapshot.docs.first.id;
      return user;
    }

    throw UsernameNotFoundException();
  }

  // Apenas o próprio usuário
  Stream<QuerySnapshot<Map<String, dynamic>>> listenSheetsByUser() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("${rc}users")
        .doc(uid)
        .collection("sheets")
        .snapshots();
  }

  // Apenas o próprio usuário
  Future<List<Sheet>> getSheetsByUser() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    List<Sheet> result = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("${rc}users")
        .doc(uid)
        .collection("sheets")
        .get();

    result = snapshot.docs.map((
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
    ) {
      return Sheet.fromMap(doc.data());
    }).toList();

    return result;
  }

  Future<Sheet?> getSheetByUser({
    required String sheetId,
    required String userId,
  }) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${rc}users")
        .doc(userId)
        .collection("sheets")
        .doc(sheetId)
        .get();

    if (doc.exists) {
      return Sheet.fromMap(doc.data()!);
    }

    return null;
  }

  // Apenas o próprio usuário
  Future<void> createSheet(String characterName, {String? campaignId}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String sheetId = Uuid().v1();
    Sheet sheet = Sheet(
      id: sheetId,
      characterName: characterName,
      stressPoints: -1,
      baseLevel: 0,
      money: 500,
      weight: 0,
      bio: "",
      notes: "",
      condition: 0,
      imageUrl: null,
      ownerId: uid,
      exhaustPoints: 0,
      listActionValue: [],
      listRollLog: [],
      listItemSheet: [],
      listActionLore: [],
      listWorks: [],
      listSharedIds: [],
      listActiveWorks: [],
      listActiveModules: [],
      listSpell: [],
      listCustomCount: [
        SheetCustomCount(
          id: energySpellModuleSCC,
          name: "Energia",
          description: "Contador de energia para módulo de magia",
          count: 6,
        ),
      ],
      booleans: {},
      indexToken: 0,
      listTokens: [],
      listCustomItems: [],
    );

    if (campaignId != null) {
      await CampaignService.instance.saveCampaignSheet(
        campaignSheet: CampaignSheet(
          userId: uid,
          campaignId: campaignId,
          sheetId: sheetId,
        ),
      );
    }

    return FirebaseFirestore.instance
        .collection("${rc}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheetId)
        .set(sheet.toMap());
  }

  // Apenas o próprio usuário
  Future<Sheet> duplicateSheet(Sheet sheet) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String sheetId = Uuid().v1();

    Sheet newSheet = sheet.copyWith(
      id: sheetId,
      characterName: "${sheet.characterName} cópia",
      ownerId: uid,
    );

    FirebaseFirestore.instance
        .collection("${rc}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheetId)
        .set(newSheet.toMap());

    return newSheet;
  }

  Future<void> duplicateSheetToMe(Sheet sheet, String? campaignId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Sheet newSheet = await duplicateSheet(sheet);

    if (campaignId != null) {
      await CampaignService.instance.saveCampaignSheet(
        campaignSheet: CampaignSheet(
          userId: uid,
          campaignId: campaignId,
          sheetId: newSheet.id,
        ),
      );
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenSheetById({
    required String id,
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collection("${rc}users")
        .doc(userId)
        .collection("sheets")
        .doc(id)
        .snapshots();
  }

  /// Tenta recuperar uma ficha pelo seu ID e o [username] da pessoa dona.
  Future<Sheet?> getSheetById({
    required String id,
    required String username,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    AppUser user = await getUserByUsername(username);

    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${rc}users")
        .doc(user.id)
        .collection("sheets")
        .doc(id)
        .get();

    List<String>? listViewers = await CampaignService.instance
        .getListPlayersIdsInWorldBySheet(id);

    if (doc.data() != null) {
      Sheet sheet = Sheet.fromMap(doc.data()!);
      if (user.id != uid &&
          !sheet.listSharedIds.contains(uid) &&
          (listViewers == null || !listViewers.contains(uid))) {
        throw UserNotAuthorizedOnSheetException();
      }
      return sheet;
    }
    return null;
  }

  /// Salva a ficha
  Future<void> saveSheet(Sheet sheet) async {
    await FirebaseFirestore.instance
        .collection("${rc}users")
        .doc(sheet.ownerId)
        .collection("sheets")
        .doc(sheet.id)
        .set(sheet.toMap());
  }

  /// Remove a ficha e sua relação com a campanha
  Future<void> removeSheet(Sheet sheet) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    if (uid != sheet.ownerId) return;

    await FirebaseFirestore.instance
        .collection("${rc}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheet.id)
        .delete();

    await FirebaseFirestore.instance
        .collection("${rc}campaign-sheet")
        .doc(sheet.id)
        .delete();
  }

  /// Sobe imagem de bio e retorna o link de download
  Future<String> uploadBioImage({
    required Uint8List bytes,
    required String sheetId,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String filePath = "users/$uid/sheets/$sheetId/bio.png";
    final fileRef = storageRef.child(filePath);

    await fileRef.putData(bytes);

    return await fileRef.getDownloadURL();
  }

  /// Remove a imagem de bio
  Future<void> deleteBioImage({required String sheetId}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String filePath = "users/$uid/sheets/$sheetId/bio.png";
    final fileRef = storageRef.child(filePath);
    return fileRef.delete();
  }

  /// Subir imagem token
  Future<String> uploadTokenImage({
    required Uint8List image,
    required String sheetId,
    required int index,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String filePath = "users/$uid/sheets/$sheetId/tokens/token-$index.png";
    final fileRef = storageRef.child(filePath);

    await fileRef.putData(image);

    return await fileRef.getDownloadURL();
  }

  /// Remover imagem de token
  Future<void> deleteTokenImage({
    required String sheetId,
    required int index,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    String filePath = "users/$uid/sheets/$sheetId/tokens/token-$index.png";
    final fileRef = storageRef.child(filePath);
    return fileRef.delete();
  }
}
