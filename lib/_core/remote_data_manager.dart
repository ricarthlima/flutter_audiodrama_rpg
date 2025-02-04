import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:uuid/uuid.dart';

import 'release_mode.dart';

class RemoteDataManager {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> listenSheetsByUser() {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .snapshots();
  }

  Future<List<Sheet>> getSheetsByUser() async {
    List<Sheet> result = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}users")
        .doc(uid)
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
          ).toMap(),
        );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenSheetById(String id) {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(id)
        .snapshots();
  }

  Future<Sheet?> getSheetId(String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(id)
        .get();

    if (doc.data() != null) {
      return Sheet.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> saveSheet(Sheet sheet) async {
    await FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheet.id)
        .set(sheet.toMap());
  }
}
