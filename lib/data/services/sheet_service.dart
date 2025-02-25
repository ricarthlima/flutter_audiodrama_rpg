import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_model.dart';
import 'package:uuid/uuid.dart';

import '../../_core/release_mode.dart';
import '../../domain/models/item_sheet.dart';

class SheetService {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> listenSheetsByUser(
      {String? userId}) {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(userId ?? uid)
        .collection("sheets")
        .snapshots();
  }

  Future<List<Sheet>> getSheetsByUser({String? userId}) async {
    List<Sheet> result = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}users")
        .doc(userId ?? uid)
        .collection("sheets")
        .get();

    result = snapshot.docs.map(
      (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return Sheet.fromMap(doc.data());
      },
    ).toList();

    return result;
  }

  Future<void> createSheet(String characterName) async {
    String sheetId = Uuid().v1();
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheetId)
        .set(
          Sheet(
            id: sheetId,
            characterName: characterName,
            listActionValue: [],
            listRollLog: [],
            effortPoints: -1,
            stressLevel: 0,
            baseLevel: 0,
            listItemSheet: [],
            money: 500,
            weight: 0,
          ).toMap(),
        );
  }

  Future<void> duplicateSheet(Sheet sheet) async {
    String sheetId = Uuid().v1();
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheetId)
        .set(
          sheet
              .copyWith(
                id: sheetId,
                characterName: "${sheet.characterName} cópia",
              )
              .toMap(),
        );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenSheetById(String id,
      {String? userId}) {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(userId ?? uid)
        .collection("sheets")
        .doc(id)
        .snapshots();
  }

  Future<Sheet?> getSheetId(String id, {String? userId}) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}users")
        .doc(userId ?? uid)
        .collection("sheets")
        .doc(id)
        .get();

    if (doc.data() != null) {
      return Sheet.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> saveSheet(Sheet sheet, {String? userId}) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(userId ?? uid)
        .collection("sheets")
        .doc(sheet.id)
        .set(sheet.toMap());
  }

  Future<void> removeSheet(Sheet sheet) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheet.id)
        .delete();
  }

  Future<void> updateSheet(
    Sheet sheet, {
    String? characterName,
    int? stressLevel,
    int? effortPoints,
    List<ActionValue>? listActionValue,
    List<RollLog>? listRollLog,
    int? baseLevel,
    List<ItemSheet>? listItemSheet,
    double? money,
    double? weight,
  }) async {
    Sheet newSheet = sheet.copyWith(
      characterName: characterName,
      stressLevel: stressLevel,
      effortPoints: effortPoints,
      listActionValue: listActionValue,
      listRollLog: listRollLog,
      baseLevel: baseLevel,
      listItemSheet: listItemSheet,
      money: money,
      weight: weight,
    );
    await saveSheet(newSheet);
  }
}
