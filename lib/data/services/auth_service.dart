import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/app_user.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:http/http.dart' as http;

import '../local/local_data_manager.dart';

class AuthService {
  Future<void> signInWithGoogle(BuildContext context) async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    final response = await http.get(
      Uri.parse(
        userCredential.user!.photoURL!,
      ),
    );
    String? base64Image;

    if (response.statusCode == 200) {
      // Codificar os bytes da imagem em base64
      base64Image = base64Encode(response.bodyBytes);

      // Salvar no SharedPreferences
      await LocalDataManager().saveImageB64(base64Image);
    } else {
      print('Erro ao baixar a imagem: ${response.statusCode}');
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
    AppRouter().goHome(context: context);
  }

  Future<void> signOut(BuildContext context) async {
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
}
