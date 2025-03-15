import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rpg_audiodrama/_core/utils/supabase_prefs.dart';
import 'package:flutter_rpg_audiodrama/domain/exceptions/sheet_service_exceptions.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../_core/release_mode.dart';

class SheetService {
  final _supabase = Supabase.instance.client;

  Future<List<String>> getListUsers() async {
    QuerySnapshot<Map<String, dynamic>> listUsersSnapshot =
        await FirebaseFirestore.instance.collection("users").get();

    final listUsers = listUsersSnapshot.docs;
    return listUsers.map((e) => e.id).toList();
  }

  Future<AppUser> getUserByUsername(String username) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .where(
              "username",
              isEqualTo: username,
            )
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
        .collection("${releaseCollection}users")
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

  // Apenas o próprio usuário
  Future<void> createSheet(String characterName) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

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
            listActionLore: [],
            bio: "",
            notes: "",
            listActiveConditions: [],
            imageUrl: null,
            listWorks: [],
            listSharedIds: [],
            ownerId: uid,
          ).toMap(),
        );
  }

  // Apenas o próprio usuário
  Future<void> duplicateSheet(Sheet sheet) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenSheetById({
    required String id,
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(userId)
        .collection("sheets")
        .doc(id)
        .snapshots();
  }

  Future<Sheet?> getSheetId({
    required String id,
    required String username,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    AppUser user = await getUserByUsername(username);

    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("${releaseCollection}users")
        .doc(user.id)
        .collection("sheets")
        .doc(id)
        .get();

    if (doc.data() != null) {
      Sheet sheet = Sheet.fromMap(doc.data()!);
      if (user.id != uid && !sheet.listSharedIds.contains(uid)) {
        throw UserNotAuthorizedOnSheetException();
      }
      return sheet;
    }
    return null;
  }

  // TODO: Por enquanto, apenas o próprio usuário
  Future<void> saveSheet(Sheet sheet) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheet.id)
        .set(sheet.toMap());
  }

  // Apenas o próprio usuário
  Future<void> removeSheet(Sheet sheet) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("${releaseCollection}users")
        .doc(uid)
        .collection("sheets")
        .doc(sheet.id)
        .delete();
  }

  // Apenas o próprio usuário
  Future<String> uploadBioImage(File file, String fileName) async {
    String result = await _supabase.storage
        .from(SupabasePrefs.storageBucketSheet)
        .upload("bios/$fileName", file);

    print(result);

    return result;
  }

  // Apenas o próprio usuário
  Future<String> uploadBioImageBytes(Uint8List file, String fileName) async {
    String bucket = SupabasePrefs.storageBucketSheet;
    String filePath = "bios/$fileName";

    await _supabase.storage.from(bucket).uploadBinary(
          filePath,
          file,
          fileOptions: FileOptions(upsert: true),
        );

    final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

    return publicUrl;
  }

  // Apenas o próprio usuário
  Future<void> deleteBioImage(String fileName) {
    return _supabase.storage
        .from(SupabasePrefs.storageBucketSheet)
        .remove(["bios/$fileName"]);
  }
}
