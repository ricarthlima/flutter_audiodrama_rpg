import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';

import '../../_core/theme_provider.dart';
import '../view/sheet_view_model.dart';

import 'package:badges/badges.dart' as badges;

Widget? getSheetFloatingActionButton(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final viewModel = Provider.of<SheetViewModel>(context);

  return ExpandableFab(
    key: viewModel.fabKey,
    type: ExpandableFabType.up,
    childrenAnimation: ExpandableFabAnimation.none,
    distance: 70,
    overlayStyle: ExpandableFabOverlayStyle(
      color: themeProvider.themeMode == ThemeMode.dark
          ? Colors.black.withAlpha(200)
          : Colors.white.withAlpha(200),
    ),
    children: [
      Row(
        children: [
          Text('Histórico'),
          SizedBox(width: 20),
          Builder(
            builder: (context) => FloatingActionButton(
              onPressed: () {
                viewModel.closeFab();
                Scaffold.of(context).openEndDrawer();
                viewModel.notificationCount = 0;
              },
              tooltip: "Histórico",
              child: badges.Badge(
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
        ],
      ),
      Row(
        children: [
          Text('Itens'),
          SizedBox(width: 20),
          FloatingActionButton(
            heroTag: null,
            tooltip: "Itens",
            onPressed: () {
              viewModel.closeFab();
              viewModel.onItemsButtonClicked(context);
            },
            child: Image.asset(
              (themeProvider.themeMode == ThemeMode.dark)
                  ? "assets/images/chest.png"
                  : "assets/images/chest-i.png",
              width: 32,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Text('Caderneta'),
          SizedBox(width: 20),
          FloatingActionButton(
            heroTag: null,
            tooltip: "Caderneta",
            onPressed: () {
              viewModel.closeFab();
              viewModel.onNotesButtonClicked(context);
            },
            child: Icon(Icons.description),
          ),
        ],
      ),
      Row(
        children: [
          Text('Estatísticas'),
          SizedBox(width: 20),
          FloatingActionButton(
            heroTag: null,
            tooltip: "Estatísticas",
            onPressed: () {
              viewModel.closeFab();
              viewModel.onStatisticsButtonClicked(context);
            },
            child: Icon(Icons.bar_chart),
          ),
        ],
      ),
    ],
  );
}
