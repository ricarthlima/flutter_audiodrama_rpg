import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';

import '../../_core/fonts.dart';
import '../../settings/settings_screen.dart';

AppBar getHomeAppBar(BuildContext context) {
  return AppBar(
    title: Text(
      "AUDIODRAMA RPG",
      style: TextStyle(
        fontFamily: FontFamily.bungee,
      ),
    ),
    elevation: 1,
    actions: [
      IconButton(
        onPressed: () {
          showSettingsDialog(context);
        },
        icon: Icon(Icons.settings),
      ),
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
