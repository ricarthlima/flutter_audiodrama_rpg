import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/app_colors.dart';
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
import '../../_core/helpers.dart';
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
  int effortPoints = -1;
  int stressLevel = 0;
  int baseLevel = 0;

  List<Sheet> listSheets = [];

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
      baseLevel = sheetModel.baseLevel;
    }

    listSheets = await RemoteDataManager().getSheetsByUser();
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
          (listSheets.isNotEmpty)
              ? DropdownButton<Sheet>(
                  value: listSheets.where((e) => e.id == widget.id).first,
                  items: listSheets
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
                      setState(() {});
                    }
                  },
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 8,
            ),
            child: VerticalDivider(),
          ),
          Visibility(
            visible: isEditing,
            child: Text("Saia da edição para salvar"),
          ),
          Visibility(
            visible: isEditing,
            child: SizedBox(width: 8),
          ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    _nameController.text = sheet.characterName;
    return Container(
      margin: EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NamedWidget(
                      title: "Nome",
                      isLeft: true,
                      child: AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        child: (isEditing)
                            ? TextField(
                                controller: _nameController,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontFamily: FontFamilies.sourceSerif4,
                                ),
                              )
                            : Text(
                                sheet.characterName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontFamily: FontFamilies.bungee,
                                  color: AppColors.red,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 16,
                        children: [
                          NamedWidget(
                            title: "Estresse",
                            hardHeight: 32,
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
                                    StressLevel().getByStressLevel(stressLevel),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FontFamilies.bungee,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (stressLevel < StressLevel.total - 1)
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
                            hardHeight: 32,
                            child: Row(
                              children: [
                                Visibility(
                                  visible: isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (effortPoints > -1)
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
                                          (themeProvider.themeMode ==
                                                  ThemeMode.dark)
                                              ? "assets/images/brain.png"
                                              : "assets/images/brain-i.png",
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
                            hardHeight: 32,
                            child: InkWell(
                              onTap: () {
                                showSnackBarWip(context);
                              },
                              child: Image.asset(
                                (themeProvider.themeMode == ThemeMode.dark)
                                    ? "assets/images/chest.png"
                                    : "assets/images/chest-i.png",
                                width: 18,
                              ),
                            ),
                          ),
                          Text("•"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: width(context) > 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 16,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(seconds: 1),
                      child: (!isEditing)
                          ? Text(
                              getBaseLevel(baseLevel),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: FontFamilies.sourceSerif4,
                              ),
                            )
                          : DropdownButton<int>(
                              value: baseLevel,
                              items: [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text("Inexperiente"),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text("Mediocre"),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text("Vivência"),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text("Experiente"),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    baseLevel = value;
                                  });
                                }
                              },
                            ),
                    ),
                    Row(
                      spacing: 32,
                      children: [
                        NamedWidget(
                          title: "Aptidões",
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                listActionValue
                                    .where(
                                      (e) => e.value == 2,
                                    )
                                    .length
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: FontFamilies.bungee,
                                ),
                              ),
                              Text(
                                "/${_getAptidaoMaxByLevel()}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamilies.sourceSerif4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NamedWidget(
                          title: "Treinamentos",
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                listActionValue
                                    .where(
                                      (e) => e.value == 3,
                                    )
                                    .length
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: FontFamilies.bungee,
                                ),
                              ),
                              Text(
                                "/${_getTreinamentoMaxByLevel()}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamilies.sourceSerif4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Flexible(
            child: SingleChildScrollView(
              child: SizedBox(
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
            ),
          ),
        ],
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
      baseLevel: baseLevel,
    );
    await RemoteDataManager().saveSheet(sheet);
  }

  onActionValueChanged(ActionValue ac) {
    if (listActionValue.where((e) => e.actionId == ac.actionId).isNotEmpty) {
      listActionValue.removeWhere((e) => e.actionId == ac.actionId);
    }
    listActionValue.add(ac);
    setState(() {});
  }

  onRoll(RollLog roll) async {
    if (!SheetDAO.instance.isOnlyFreeOrPreparation(roll.idAction)) {
      showRollDialog(context: context, rollLog: roll);
    }
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
      effortPoints = max(effortPoints - 1, -1);
    }
    setState(() {});
  }

  int _getAptidaoMaxByLevel() {
    switch (baseLevel) {
      case 0:
        return 9;
      case 1:
        return 17;
      case 2:
        return 25;
      case 3:
        return 33;
    }
    return 9;
  }

  int _getTreinamentoMaxByLevel() {
    switch (baseLevel) {
      case 0:
        return 1;
      case 1:
        return 3;
      case 2:
        return 5;
      case 3:
        return 7;
    }
    return 9;
  }
}

class NamedWidget extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget child;
  final double? hardHeight;
  final bool isLeft;
  const NamedWidget({
    super.key,
    required this.title,
    this.titleWidget,
    required this.child,
    this.hardHeight,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          (isLeft) ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        (titleWidget != null)
            ? titleWidget!
            : SizedBox(
                height: 16,
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontFamilies.sourceSerif4,
                    fontSize: 10,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color!
                        .withAlpha(150),
                  ),
                ),
              ),
        (hardHeight != null)
            ? SizedBox(height: hardHeight, child: child)
            : child,
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

Future<dynamic> showRollDialog({
  required BuildContext context,
  required RollLog rollLog,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: RollRowWidget(rollLog: rollLog),
      );
    },
  );
}

class RollRowWidget extends StatefulWidget {
  final RollLog rollLog;
  const RollRowWidget({
    super.key,
    required this.rollLog,
  });

  @override
  State<RollRowWidget> createState() => _RollRowWidgetState();
}

class _RollRowWidgetState extends State<RollRowWidget> {
  int i = 0;
  List<double> listOpacity = [0, 0, 0];
  bool isShowingHighlighted = false;

  @override
  void initState() {
    super.initState();
    callShowRoll();
  }

  callShowRoll() async {
    await Future.delayed(Duration(milliseconds: 250));
    setState(() {
      listOpacity[i] = 1;
    });
    i++;
    if (i < widget.rollLog.rolls.length) {
      callShowRoll();
    } else {
      makeCorrectHighlighted();
    }
  }

  makeCorrectHighlighted() async {
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() {
      isShowingHighlighted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 64,
      children: List.generate(
        widget.rollLog.rolls.length,
        (index) {
          return AnimatedOpacity(
            opacity: listOpacity[index],
            duration: Duration(milliseconds: 750),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 750),
                    child: Image.asset(
                      (!isShowingHighlighted)
                          ? "assets/images/d20-1.png"
                          : (widget.rollLog.isGettingLower)
                              ? (widget.rollLog.rolls.reduce(min) ==
                                      widget.rollLog.rolls[index])
                                  ? "assets/images/d20-0.png"
                                  : "assets/images/d20-1.png"
                              : (widget.rollLog.rolls.reduce(max) ==
                                      widget.rollLog.rolls[index])
                                  ? "assets/images/d20-4.png"
                                  : "assets/images/d20-1.png",
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.rollLog.rolls[index].toString(),
                      style: TextStyle(
                        fontSize: 44,
                        fontFamily: FontFamilies.bungee,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
