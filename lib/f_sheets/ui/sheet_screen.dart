import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/_core/remote_data_manager.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/data/sheet_template.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/ui/components/sheet_history_drawer.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_core/theme_provider.dart';
import 'widgets/list_actions_widget.dart';

class SheetScreen extends StatefulWidget {
  final String id;
  const SheetScreen({super.key, required this.id});

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  Future<SheetModel?> futureGetSheet = Future.delayed(Duration.zero);
  List<ActionValue> listActionValue = [];
  List<RollLog> listRollLog = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  Future<void> refresh() async {
    futureGetSheet = RemoteDataManager().getSheetId(widget.id);

    SheetModel? sheetModel = await futureGetSheet;
    if (sheetModel != null) {
      listActionValue = sheetModel.listActionValue;
      listRollLog = sheetModel.listRollLog;
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
            child: Text("Sair da edição para salvar"),
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
              },
              icon: Icon(Icons.chat),
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

  Widget _generateScreen(SheetModel sheet) {
    _nameController.text = sheet.characterName;
    return Container(
      margin: EdgeInsets.all(16),
      padding: const EdgeInsets.all(64),
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
              height: 150,
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
    SheetModel sheet = SheetModel(
      id: widget.id,
      characterName: _nameController.text,
      listActionValue: listActionValue,
      listRollLog: listRollLog,
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
    setState(() {});
  }
}
