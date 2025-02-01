import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../_core/local_data_manager.dart';

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

    if (response.statusCode == 200) {
      // Codificar os bytes da imagem em base64
      String base64Image = base64Encode(response.bodyBytes);

      // Salvar no SharedPreferences
      await LocalDataManager().saveImageB64(base64Image);
    } else {
      print('Erro ao baixar a imagem: ${response.statusCode}');
    }

    if (!context.mounted) return;
    GoRouter.of(context).go(AppRouter.home);
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    GoRouter.of(context).go(AppRouter.auth);
  }
}
