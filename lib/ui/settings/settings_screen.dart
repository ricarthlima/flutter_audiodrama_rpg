import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:provider/provider.dart';

import '../../router.dart';
import 'view/settings_provider.dart';

Future<dynamic> showSettingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(child: SettingsScreen());
    },
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SizedBox(
      width: min(400, width(context)),
      height: min(800, height(context)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Configurações"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Modo escuro"),
                    Row(
                      children: [
                        Icon(Icons.light_mode),
                        Switch(
                          value: settingsProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            settingsProvider.toggleTheme(value);
                          },
                        ),
                        Icon(Icons.dark_mode),
                      ],
                    ),
                  ],
                ),
                Divider(height: 32),
                ListTile(
                  onTap: () {
                    FirebaseAuth.instance.signOut().then(
                      (value) {
                        if (!context.mounted) return;
                        AppRouter().goAuth(context: context);
                      },
                    );
                  },
                  leading: Icon(Icons.logout),
                  title: Text("Sair"),
                  contentPadding: EdgeInsets.zero,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
