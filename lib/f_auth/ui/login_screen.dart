import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../_core/local_data_manager.dart';
import '../models/signed_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  SignedUser? currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: (currentUser == null)
            ? ElevatedButton(
                onPressed: () {
                  signInWithGoogle();
                },
                child: Text("Login com o Google"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: listByCurrentUser(currentUser!),
              ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
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

      currentUser = SignedUser(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName!,
        email: userCredential.user!.email!,
        imageUrl: userCredential.user!.photoURL!,
        imageB64: base64Image,
      );
    } else {
      print('Erro ao baixar a imagem: ${response.statusCode}');
    }

    setState(() {});

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    setState(() {});
  }

  List<Widget> listByCurrentUser(SignedUser user) {
    TextEditingController myController =
        TextEditingController(text: user.imageUrl);
    return [
      Image.memory(base64Decode(user.imageB64)),
      Text(user.id),
      Text(user.email),
      TextFormField(
        controller: myController,
      ),
      ElevatedButton(
        onPressed: () {
          signOut();
        },
        child: Text("Deslogar"),
      ),
    ];
  }
}
