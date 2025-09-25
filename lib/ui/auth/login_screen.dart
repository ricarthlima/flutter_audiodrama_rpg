import 'package:flutter/material.dart';
import '../_core/fonts.dart';
import '../../data/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../_core/app_colors.dart';
import 'widgets/auth_buttons.dart';
import '../settings/view/settings_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "AUDIODRAMA ",
              style: TextStyle(fontFamily: FontFamily.bungee),
            ),
            Text(
              "RPG",
              style: TextStyle(
                fontFamily: FontFamily.bungee,
                color: AppColors.red,
              ),
            ),
          ],
        ),
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
