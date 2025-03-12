import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:provider/provider.dart';

import '../../_core/fonts.dart';
import '../../settings/settings_screen.dart';
import '../view/home_view_model.dart';

AppBar getHomeAppBar(BuildContext context) {
  final viewModel = Provider.of<HomeViewModel>(context);
  return AppBar(
    leading: IconButton(
      onPressed: () {
        viewModel.isDrawerClosed = !viewModel.isDrawerClosed;
      },
      icon: Icon(Icons.menu),
    ),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "AUDIODRAMA ",
          style: TextStyle(
            fontFamily: FontFamily.bungee,
          ),
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
    elevation: 1,
    actions: [
      IconButton(
        onPressed: () {
          showSettingsDialog(context);
        },
        icon: Icon(Icons.settings),
      ),
      if (!isVertical(context))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: VerticalDivider(),
        ),
      if (!isVertical(context))
        IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut().then(
              (value) {
                if (!context.mounted) return;
                AppRouter().goAuth(context: context);
              },
            );
          },
          icon: Icon(Icons.logout),
        ),
      SizedBox(width: 16),
    ],
  );
}
