import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../_core/fonts.dart';
import '../../_core/theme_provider.dart';

AppBar getHomeAppBar(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return AppBar(
    title: Text(
      "AUDIODRAMA RPG",
      style: TextStyle(
        fontFamily: FontFamily.bungee,
      ),
    ),
    elevation: 1,
    actions: [
      Icon(Icons.light_mode),
      Switch(
        value: themeProvider.themeMode == ThemeMode.dark,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
      ),
      Icon(Icons.dark_mode),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: VerticalDivider(),
      ),
      IconButton(
        onPressed: () {
          FirebaseAuth.instance.signOut().then(
            (value) {
              if (!context.mounted) return;
              GoRouter.of(context).go(AppRouter.auth);
            },
          );
        },
        icon: Icon(Icons.logout),
      ),
      SizedBox(width: 16),
    ],
  );
}
