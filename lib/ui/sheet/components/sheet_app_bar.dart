import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sheet_model.dart';
import '../../../router.dart';
import '../../_core/dimensions.dart';
import '../../_core/theme_provider.dart';
import '../view/sheet_view_model.dart';

import 'package:badges/badges.dart' as badges;

AppBar getSheetAppBar(BuildContext context) {
  final viewModel = Provider.of<SheetViewModel>(context);
  final themeProvider = Provider.of<ThemeProvider>(context);

  return AppBar(
    toolbarHeight: 64,
    leading: IconButton(
      onPressed: () {
        GoRouter.of(context).go(AppRouter.home);
      },
      icon: Icon(Icons.arrow_back),
    ),
    actions: [
      Visibility(
        visible: !isVertical(context),
        child: (viewModel.listSheets.isNotEmpty)
            ? DropdownButton<Sheet>(
                value: viewModel.listSheets
                    .where((e) => e.id == viewModel.id)
                    .first,
                items: viewModel.listSheets
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.characterName),
                      ),
                    )
                    .toList(),
                onChanged: (Sheet? sheet) {
                  if (sheet != null) {
                    GoRouter.of(context).go("${AppRouter.sheet}/${sheet.id}");
                  }
                },
              )
            : Container(),
      ),
      Visibility(
        visible: !isVertical(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 8,
          ),
          child: VerticalDivider(),
        ),
      ),
      Visibility(
        visible: viewModel.isEditing,
        child: Text("Saia da edição para salvar"),
      ),
      Visibility(
        visible: viewModel.isEditing,
        child: SizedBox(width: 8),
      ),
      Icon(Icons.edit),
      Switch(
        value: viewModel.isEditing,
        onChanged: (value) {
          viewModel.toggleEditMode();
        },
      ),
      if (!isVertical(context))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: VerticalDivider(),
        ),
      if (!isVertical(context)) Icon(Icons.light_mode),
      if (!isVertical(context))
        Switch(
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
        ),
      if (!isVertical(context)) Icon(Icons.dark_mode),
      if (!isVertical(context))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: VerticalDivider(),
        ),
      if (!isVertical(context))
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
              viewModel.notificationCount = 0;
            },
            icon: badges.Badge(
              showBadge: viewModel.notificationCount >
                  0, // Esconde se não houver notificações
              badgeContent: Text(
                viewModel.notificationCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              position: badges.BadgePosition.topEnd(
                top: -10,
                end: -12,
              ), // Ajusta posição
              child: Icon(Icons.chat),
            ),
          ),
        ),
      SizedBox(width: 16),
    ],
  );
}
