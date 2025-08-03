import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/models/app_user.dart';
import '../../router.dart';
import '../../_core/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../preferences/local_data_manager.dart';

class AuthService {
  Future<void> signInWithGoogle(BuildContext context) async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    UserCredential? userCredential;
    // Once signed in, return the UserCredential

    if (kIsWeb) {
      userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      userCredential =
          await FirebaseAuth.instance.signInWithProvider(googleProvider);
    }

    String? base64Image;

    final response = await http.get(
      Uri.parse(
        userCredential.user!.photoURL!,
      ),
    );

    if (response.statusCode == 200) {
      // Codificar os bytes da imagem em base64
      base64Image = base64Encode(response.bodyBytes);

      // Salvar no SharedPreferences
      await LocalDataManager.instance.saveImageB64(base64Image);
    } else {
      Logger().i('Erro ao baixar a imagem: ${response.statusCode}');
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    String email = FirebaseAuth.instance.currentUser!.email!;

    AppUser appUser = AppUser(
      id: uid,
      email: email,
      imageB64: base64Image,
    );

    await registerUser(appUser);

    if (!context.mounted) return;
    await Provider.of<UserProvider>(context, listen: false).onInitialize();

    if (!context.mounted) return;
    AppRouter().goHome(context: context);
  }

  Future<void> signOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).onDispose();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    AppRouter().goAuth(context: context);
  }

  Future<void> registerUser(AppUser appUser) async {
    DocumentSnapshot<Map<String, dynamic>> query = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(appUser.id)
        .get();

    if (!query.exists) {
      // TODO: Resolver casos de usernames duplicados
      appUser.username =
          "${appUser.email!.split("@")[0]}-${Random().nextInt(99999) + 10000}";
      await FirebaseFirestore.instance
          .collection("users")
          .doc(appUser.id)
          .set(appUser.toMap());
    }
  }

  Future<AppUser?> getCurrentUserInfos() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> docs =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docs.data() != null) {
      return AppUser.fromMap(docs.data()!);
    }

    return null;
  }

  Future<AppUser?> getUserInfosById({required String userId}) async {
    DocumentSnapshot<Map<String, dynamic>> docs =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    if (docs.data() != null) {
      return AppUser.fromMap(docs.data()!);
    }

    return null;
  }

  Future<List<AppUser>> getUserInfoByListIds({
    required List<String> listIds,
  }) async {
    List<AppUser?> users = await Future.wait(
      listIds.map((id) => getUserInfosById(userId: id)),
    );

    return users.whereType<AppUser>().toList();
  }
}
