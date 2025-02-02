import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/_core/remote_data_manager.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/data/stress_level.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/data/sheet_template.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/ui/components/sheet_history_drawer.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_core/theme_provider.dart';
import 'widgets/list_actions_widget.dart';
import 'package:badges/badges.dart' as badges;

class SheetScreen extends StatefulWidget {
  final String id;
  const SheetScreen({super.key, required this.id});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  Future<Sheet?> futureGetSheet = Future.delayed(Duration.zero);
  List<ActionValue> listActionValue = [];
  List<RollLog> listRollLog = [];
  int notificationCount = 0;
  int effortPoints = 0;
  int stressLevel = 0;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  Future<void> refresh() async {
    futureGetSheet = RemoteDataManager().getSheetId(widget.id);

    Sheet? sheetModel = await futureGetSheet;
    if (sheetModel != null) {
      listActionValue = sheetModel.listActionValue;
      listRollLog = sheetModel.listRollLog;
      effortPoints = sheetModel.effortPoints;
      stressLevel = sheetModel.stressLevel;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).go(AppRouter.home);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Visibility(
            visible: isEditing,
            child: Text("Saia da edição para salvar"),
          ),
          SizedBox(width: 8),
          Icon(Icons.edit),
          Switch(
            value: isEditing,
            onChanged: (value) {
              toggleEditMode();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: VerticalDivider(),
          ),
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
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
                setState(() {
                  notificationCount = 0;
                });
              },
              icon: badges.Badge(
                showBadge:
                    notificationCount > 0, // Esconde se não houver notificações
                badgeContent: Text(
                  notificationCount.toString(),
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
      ),
      endDrawer: Drawer(
        child: SheetHistoryDrawer(listRollLog: listRollLog),
      ),
      body: FutureBuilder(
        future: futureGetSheet,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.data != null) {
                return _generateScreen(snapshot.data!);
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Text("Ficha não encontrada"),
                    ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).go(AppRouter.home);
                      },
                      child: Text("Voltar"),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _generateScreen(Sheet sheet) {
    _nameController.text = sheet.characterName;
    return Container(
      margin: EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 32,
          children: [
            SizedBox(
              height: 175,
              child: Row(
                spacing: 32,
                children: [
                  SizedBox(
                    width: 150,
                    height: 200,
                    child: Stack(
                      children: [
                        Image.network(
                          "https://m.media-amazon.com/images/I/71XQaMRKLML._AC_SL1500_.jpg",
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Visibility(
                            visible: isEditing,
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.edit),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nome:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: FontsFamilies.sourceSerif4,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          child: (isEditing)
                              ? TextField(
                                  controller: _nameController,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontFamily: FontsFamilies.sourceSerif4,
                                  ),
                                )
                              : Text(
                                  sheet.characterName,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontFamily: FontsFamilies.bungee,
                                  ),
                                ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          spacing: 16,
                          children: [
                            NamedWidget(
                              title: "Estresse",
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: isEditing,
                                    child: SizedBox(
                                      width: 32,
                                      child: (stressLevel > 0)
                                          ? IconButton(
                                              onPressed: () {
                                                changeStressLevel(
                                                    isAdding: false);
                                              },
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.remove),
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      StressLevel()
                                          .getByStressLevel(stressLevel),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FontsFamilies.bungee,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isEditing,
                                    child: SizedBox(
                                      width: 32,
                                      child:
                                          (stressLevel < StressLevel.total - 1)
                                              ? IconButton(
                                                  onPressed: () {
                                                    changeStressLevel();
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(Icons.add),
                                                )
                                              : Container(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text("•"),
                            NamedWidget(
                              title: "Esforço",
                              child: Row(
                                children: [
                                  Visibility(
                                    visible: isEditing,
                                    child: SizedBox(
                                      width: 32,
                                      child: (effortPoints > 0)
                                          ? IconButton(
                                              onPressed: () {
                                                changeEffortPoints(
                                                  isAdding: false,
                                                );
                                              },
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.remove),
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  Row(
                                    spacing: 8,
                                    children: List.generate(
                                      3,
                                      (index) {
                                        return Opacity(
                                          opacity:
                                              (index <= effortPoints) ? 1 : 0.5,
                                          child: Image.asset(
                                            "assets/images/brain.png",
                                            width: 16,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Visibility(
                                    visible: isEditing,
                                    child: SizedBox(
                                      width: 32,
                                      child: (effortPoints < 3)
                                          ? IconButton(
                                              onPressed: () {
                                                changeEffortPoints();
                                              },
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.add),
                                            )
                                          : Container(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text("•"),
                            NamedWidget(
                              title: "Itens",
                              child: InkWell(
                                onTap: () {
                                  showSnackBarWip(context);
                                },
                                child: Image.asset(
                                  "assets/images/chest.png",
                                  width: 18,
                                ),
                              ),
                            ),
                            Text("•"),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              width: width(context),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.center,
                runSpacing: 32,
                children: [
                  ListActionsWidget(
                    name: "Ações Básicas",
                    sheet: sheet,
                    isEditing: isEditing,
                    listActions: SheetDAO.instance.listBasicActions,
                    onActionValueChanged: onActionValueChanged,
                    onRoll: onRoll,
                  ),
                  ListActionsWidget(
                    name: "Ações de Força",
                    sheet: sheet,
                    isEditing: isEditing,
                    listActions: SheetDAO.instance.listStrengthActions,
                    onActionValueChanged: onActionValueChanged,
                    onRoll: onRoll,
                  ),
                  ListActionsWidget(
                    name: "Ações de Agilidade",
                    sheet: sheet,
                    isEditing: isEditing,
                    listActions: SheetDAO.instance.listAgilityActions,
                    onActionValueChanged: onActionValueChanged,
                    onRoll: onRoll,
                  ),
                  ListActionsWidget(
                    name: "Ações de Intelecto",
                    sheet: sheet,
                    isEditing: isEditing,
                    listActions: SheetDAO.instance.listIntellectActions,
                    onActionValueChanged: onActionValueChanged,
                    onRoll: onRoll,
                  ),
                  ListActionsWidget(
                    name: "Ações Sociais",
                    sheet: sheet,
                    isEditing: isEditing,
                    listActions: SheetDAO.instance.listSocialActions,
                    onActionValueChanged: onActionValueChanged,
                    onRoll: onRoll,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleEditMode() async {
    if (!isEditing) {
      setState(() {
        isEditing = true;
      });
    } else {
      await saveChanges();
      setState(() {
        isEditing = false;
      });
      refresh();
    }
  }

  Future<void> saveChanges() async {
    Sheet sheet = Sheet(
      id: widget.id,
      characterName: _nameController.text,
      listActionValue: listActionValue,
      listRollLog: listRollLog,
      effortPoints: effortPoints,
      stressLevel: stressLevel,
    );
    await RemoteDataManager().saveSheet(sheet);
  }

  onActionValueChanged(ActionValue ac) {
    if (listActionValue.where((e) => e.actionId == ac.actionId).isNotEmpty) {
      listActionValue.removeWhere((e) => e.actionId == ac.actionId);
    }
    listActionValue.add(ac);
  }

  onRoll(RollLog roll) async {
    listRollLog.add(roll);
    await saveChanges();
    notificationCount++;
    setState(() {});
  }

  changeStressLevel({bool isAdding = true}) {
    if (isAdding) {
      stressLevel = min(stressLevel + 1, 3);
    } else {
      stressLevel = max(stressLevel - 1, 0);
    }
    setState(() {});
  }

  changeEffortPoints({bool isAdding = true}) {
    if (isAdding) {
      effortPoints = min(effortPoints + 1, 2);
    } else {
      effortPoints = max(effortPoints - 1, 0);
    }
    setState(() {});
  }
}

class NamedWidget extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget child;
  const NamedWidget({
    super.key,
    required this.title,
    this.titleWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (titleWidget != null)
            ? titleWidget!
            : SizedBox(
                height: 16,
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontsFamilies.sourceSerif4,
                    fontSize: 10,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color!
                        .withAlpha(150),
                  ),
                ),
              ),
        SizedBox(height: 32, child: child),
      ],
    );
  }
}

showSnackBarWip(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Ainda não implementado. Fica pra próxima versão :)"),
      duration: Duration(milliseconds: 1200),
    ),
  );
}
