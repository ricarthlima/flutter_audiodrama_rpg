import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/stress_level.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_history_drawer.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../_core/components/wip_snackbar.dart';
import '../_core/helpers.dart';
import '../_core/theme_provider.dart';
import '../_core/widgets/named_widget.dart';
import 'widgets/list_actions_widget.dart';
import 'package:badges/badges.dart' as badges;

class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SheetViewModel>(context, listen: false);
      viewModel.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final viewModel = Provider.of<SheetViewModel>(context);

    return Scaffold(
      floatingActionButton: isVertical(context)
          ? FloatingActionButton(
              onPressed: () => viewModel.onItemsButtonClicked(context),
              child: Image.asset(
                (themeProvider.themeMode == ThemeMode.dark)
                    ? "assets/images/chest.png"
                    : "assets/images/chest-i.png",
                width: 32,
              ),
            )
          : null,
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
                        GoRouter.of(context)
                            .go("${AppRouter.sheet}/${sheet.id}");
                        setState(() {});
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
            visible: viewModel.isEditing && !isVertical(context),
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
                  viewModel.notificationCount = 0;
                });
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
      ),
      endDrawer: Drawer(
        child: SheetHistoryDrawer(listRollLog: viewModel.listRollLog),
      ),
      body: FutureBuilder(
        future: viewModel.futureGetSheet,
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
    final viewModel = Provider.of<SheetViewModel>(context);

    viewModel.nameController.text = sheet.characterName;
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(isVertical(context) ? 16 : 32),
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                        child: (viewModel.isEditing)
                            ? TextField(
                                controller: viewModel.nameController,
                                style: TextStyle(
                                  fontSize: isVertical(context) ? 18 : 48,
                                  fontFamily: FontFamily.sourceSerif4,
                                ),
                              )
                            : Text(
                                sheet.characterName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isVertical(context) ? 18 : 48,
                                  fontFamily: FontFamily.bungee,
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
                            tooltip: "Nível de estresse atual",
                            hardHeight: 32,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: viewModel.isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (viewModel.stressLevel > 0)
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.changeStressLevel(
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
                                    StressLevel().getByStressLevel(
                                        viewModel.stressLevel),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FontFamily.bungee,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: viewModel.isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (viewModel.stressLevel <
                                            StressLevel.total - 1)
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.changeStressLevel();
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
                            tooltip: "Carga de esforço acumulada",
                            hardHeight: 32,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: viewModel.isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (viewModel.effortPoints > -1)
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.changeEffortPoints(
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
                                            (index <= viewModel.effortPoints)
                                                ? 1
                                                : 0.5,
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
                                  visible: viewModel.isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (viewModel.effortPoints < 3)
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.changeEffortPoints();
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
                            title: "Mod. Global",
                            tooltip: "Modificador global de treinamento",
                            hardHeight: 32,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: viewModel.isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (viewModel.modGlobalTrain > -4)
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.changeModGlobal(
                                                  isAdding: false);
                                            },
                                            padding: EdgeInsets.zero,
                                            icon: Icon(Icons.remove),
                                          )
                                        : Container(),
                                  ),
                                ),
                                SizedBox(
                                  width: 42,
                                  child: Text(
                                    viewModel.modGlobalTrain.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FontFamily.bungee,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: viewModel.isEditing,
                                  child: SizedBox(
                                    width: 32,
                                    child: (viewModel.modGlobalTrain < 4)
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.changeModGlobal();
                                            },
                                            padding: EdgeInsets.zero,
                                            icon: Icon(Icons.add),
                                          )
                                        : Container(),
                                  ),
                                ),
                                Visibility(
                                  visible: viewModel.isEditing,
                                  child: Tooltip(
                                    message: "Manter modificador",
                                    child: Checkbox(
                                      value: viewModel.modGlobalKeep,
                                      onChanged: (value) {
                                        setState(() {
                                          viewModel.modGlobalKeep =
                                              !viewModel.modGlobalKeep;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text("•"),
                          NamedWidget(
                            isVisible: !isVertical(context),
                            title: "Itens",
                            tooltip: "Clique para abrir inventário",
                            hardHeight: 32,
                            child: InkWell(
                              onTap: () =>
                                  viewModel.onItemsButtonClicked(context),
                              child: Image.asset(
                                (themeProvider.themeMode == ThemeMode.dark)
                                    ? "assets/images/chest.png"
                                    : "assets/images/chest-i.png",
                                width: 18,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !isVertical(context),
                            child: Text("•"),
                          ),
                          NamedWidget(
                            isVisible: !isVertical(context),
                            title: "Condições",
                            tooltip: "Clique visualizar condições atuais",
                            hardHeight: 32,
                            child: InkWell(
                              onTap: () {
                                showSnackBarWip(context);
                              },
                              child: Icon(
                                Icons.personal_injury_outlined,
                                size: 18,
                              ),
                            ),
                          ),
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
                      child: (!viewModel.isEditing)
                          ? Text(
                              getBaseLevel(viewModel.baseLevel),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: FontFamily.sourceSerif4,
                              ),
                            )
                          : DropdownButton<int>(
                              value: viewModel.baseLevel,
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
                                    viewModel.baseLevel = value;
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
                                viewModel.listActionValue
                                    .where(
                                      (e) => e.value == 2,
                                    )
                                    .length
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: FontFamily.bungee,
                                ),
                              ),
                              Text(
                                "/${viewModel.getAptidaoMaxByLevel()}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamily.sourceSerif4,
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
                                viewModel.listActionValue
                                    .where(
                                      (e) => e.value == 3,
                                    )
                                    .length
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: FontFamily.bungee,
                                ),
                              ),
                              Text(
                                "/${viewModel.getTreinamentoMaxByLevel()}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamily.sourceSerif4,
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
                      isEditing: viewModel.isEditing,
                      listActions: ActionDAO.instance.listBasicActions,
                      onActionValueChanged: viewModel.onActionValueChanged,
                      onRoll: (roll) => viewModel.onRoll(context, roll: roll),
                      modRoll: viewModel.modGlobalTrain,
                    ),
                    ListActionsWidget(
                      name: "Ações de Força",
                      sheet: sheet,
                      isEditing: viewModel.isEditing,
                      listActions: ActionDAO.instance.listStrengthActions,
                      onActionValueChanged: viewModel.onActionValueChanged,
                      onRoll: (roll) => viewModel.onRoll(context, roll: roll),
                      modRoll: viewModel.modGlobalTrain,
                    ),
                    ListActionsWidget(
                      name: "Ações de Agilidade",
                      sheet: sheet,
                      isEditing: viewModel.isEditing,
                      listActions: ActionDAO.instance.listAgilityActions,
                      onActionValueChanged: viewModel.onActionValueChanged,
                      onRoll: (roll) => viewModel.onRoll(context, roll: roll),
                      modRoll: viewModel.modGlobalTrain,
                    ),
                    ListActionsWidget(
                      name: "Ações de Intelecto",
                      sheet: sheet,
                      isEditing: viewModel.isEditing,
                      listActions: ActionDAO.instance.listIntellectActions,
                      onActionValueChanged: viewModel.onActionValueChanged,
                      onRoll: (roll) => viewModel.onRoll(context, roll: roll),
                      modRoll: viewModel.modGlobalTrain,
                    ),
                    ListActionsWidget(
                      name: "Ações Sociais",
                      sheet: sheet,
                      isEditing: viewModel.isEditing,
                      listActions: ActionDAO.instance.listSocialActions,
                      onActionValueChanged: viewModel.onActionValueChanged,
                      onRoll: (roll) => viewModel.onRoll(context, roll: roll),
                      modRoll: viewModel.modGlobalTrain,
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
}
