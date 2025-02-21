import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/data/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'widgets/auth_buttons.dart';
import '../_core/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AUDIODRAMA RPG",
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
        ),
        actions: [
          Icon(Icons.light_mode),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          Icon(Icons.dark_mode),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: GoogleAuthButtonWidget(
          onPressed: () {
            AuthService().signInWithGoogle(context);
          },
          themeMode: themeProvider.themeMode,
        ),
      ),
    );
  }
}
