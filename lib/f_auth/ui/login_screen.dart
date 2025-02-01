import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/f_auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AUDIODRAMA RPG",
          style: TextStyle(
            fontFamily: FontsFamilies.bungee,
          ),
        ),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          AuthService().signInWithGoogle(context);
        },
        child: Text("Login com o Google"),
      )),
    );
  }
}
