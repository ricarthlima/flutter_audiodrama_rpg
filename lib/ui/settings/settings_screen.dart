import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../_core/providers/audio_provider.dart';
import '../_core/dimensions.dart';
import '../_core/fonts.dart';
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
    final audioProvider = Provider.of<AudioProvider>(context);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Text(
                  "Geral",
                  style: TextStyle(fontFamily: FontFamily.bungee),
                ),
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
                Divider(
                  height: 32,
                  thickness: 0.5,
                ),
                Text(
                  "Audio",
                  style: TextStyle(fontFamily: FontFamily.bungee),
                ),
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Global"),
                    Slider(
                      value: safeVolume(audioProvider.globalLocalVolume),
                      min: 0,
                      max: 1,
                      divisions: 9,
                      padding: EdgeInsets.zero,
                      label: audioProvider.globalLocalVolume.toStringAsFixed(1),
                      onChanged: (value) {
                        audioProvider.changeGlobalVolume(value);
                      },
                    ),
                    Text("Músicas"),
                    Slider(
                      value: safeVolume(audioProvider.mscLocalVolume),
                      min: 0,
                      max: 1,
                      divisions: 9,
                      padding: EdgeInsets.zero,
                      label: audioProvider.mscLocalVolume.toStringAsFixed(1),
                      onChanged: (value) {
                        audioProvider.changeLocalMusicVolume(value);
                      },
                    ),
                    Text("Ambientação"),
                    Slider(
                      value: safeVolume(audioProvider.ambLocalVolume),
                      min: 0,
                      max: 1,
                      divisions: 9,
                      padding: EdgeInsets.zero,
                      label: audioProvider.ambLocalVolume.toStringAsFixed(1),
                      onChanged: (value) {
                        audioProvider.changeLocalAmbientVolume(value);
                      },
                    ),
                    Text("Efeitos"),
                    Slider(
                      value: safeVolume(audioProvider.sfxLocalVolume),
                      min: 0,
                      max: 1,
                      divisions: 9,
                      padding: EdgeInsets.zero,
                      label: audioProvider.sfxLocalVolume.toStringAsFixed(1),
                      onChanged: (value) {
                        audioProvider.changeLocalSfxVolume(value);
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 32,
                  thickness: 0.5,
                ),
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
                  title: Text("Deslogar"),
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
