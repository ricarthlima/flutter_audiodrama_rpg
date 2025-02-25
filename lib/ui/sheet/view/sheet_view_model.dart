import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rpg_audiodrama/data/services/sheet_service.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:provider/provider.dart';

import '../../../data/daos/action_dao.dart';
import '../../../domain/models/action_template.dart';
import '../../../domain/models/item_sheet.dart';
import '../../../domain/models/sheet_model.dart';
import '../../shopping/shopping_screen.dart';
import '../components/action_dialog_tooltip.dart';
import '../components/roll_dialog.dart';

class SheetViewModel extends ChangeNotifier {
  String id;
  String? userId;

  updateCredentials({String? id, String? userId}) {
    this.id = id ?? this.id;
    this.userId = userId;
  }

  SheetViewModel({required this.id, this.userId});

  GlobalKey<ExpandableFabState> fabKey = GlobalKey<ExpandableFabState>();

  closeFab() {
    final state = fabKey.currentState;
    if (state != null) {
      state.toggle();
    }
  }

  SheetService sheetService = SheetService();
  final ActionDAO _actionDAO = ActionDAO.instance;

  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  Future<Sheet?> futureGetSheet = Future.delayed(Duration.zero);
  List<ActionValue> listActionValue = [];
  List<RollLog> listRollLog = [];

  int _notificationCount = 0;

  int get notificationCount => _notificationCount;
  set notificationCount(int value) {
    _notificationCount = value;
    notifyListeners();
  }

  int effortPoints = -1;
  int stressLevel = 0;
  int baseLevel = 0;
  double money = 0;
  double weight = 0;

  int modGlobalTrain = 0;
  bool isKeepingGlobalModifier = false;

  List<ItemSheet> listSheetItems = [];

  List<Sheet> listSheets = [];

  Sheet? sheet;

  bool _isLoading = true;

  get isLoading => _isLoading;

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    startLoading();

    futureGetSheet = sheetService.getSheetId(
      id,
      userId: userId,
    );

    Sheet? sheetModel = await futureGetSheet;

    if (sheetModel != null) {
      listActionValue = sheetModel.listActionValue;
      listRollLog = sheetModel.listRollLog;
      effortPoints = sheetModel.effortPoints;
      stressLevel = sheetModel.stressLevel;
      baseLevel = sheetModel.baseLevel;
      listSheetItems = sheetModel.listItemSheet;
      money = sheetModel.money;
      weight = sheetModel.weight;

      sheet = sheetModel;
    }

    listSheets = await SheetService().getSheetsByUser(
      userId: userId,
    );

    stopLoading();
  }

  void toggleEditMode() async {
    if (!isEditing) {
      isEditing = true;
      notifyListeners();
    } else {
      await saveChanges();
      isEditing = false;
      notifyListeners();
      refresh();
    }
  }

  Future<void> saveChanges() async {
    Sheet sheet = Sheet(
      id: id,
      characterName: nameController.text,
      listActionValue: listActionValue,
      listRollLog: listRollLog,
      effortPoints: effortPoints,
      stressLevel: stressLevel,
      baseLevel: baseLevel,
      listItemSheet: listSheetItems,
      money: money,
      weight: weight,
    );
    await SheetService().saveSheet(
      sheet,
      userId: userId,
    );
  }

  onActionValueChanged(ActionValue ac) {
    if (listActionValue.where((e) => e.actionId == ac.actionId).isNotEmpty) {
      listActionValue.removeWhere((e) => e.actionId == ac.actionId);
    }
    listActionValue.add(ac);
    notifyListeners();
  }

  onRoll(BuildContext context, {required RollLog roll}) async {
    ActionTemplate? action = _actionDAO.getActionById(roll.idAction);

    if (!_actionDAO.isOnlyFreeOrPreparation(roll.idAction) ||
        _actionDAO.isLuckAction(roll.idAction)) {
      showRollDialog(context: context, rollLog: roll);
    } else {
      if (action != null) {
        showDialogTip(
          context,
          action,
          isEffortUsed: action.isPreparation,
        );
      }
    }

    listRollLog.add(roll);
    await saveChanges();
    notificationCount++;

    if (!isKeepingGlobalModifier) {
      modGlobalTrain = 0;
    }

    notifyListeners();

    if (action != null && action.isPreparation) {
      effortPoints++;
      if (effortPoints >= 2) {
        effortPoints = -1;
        changeStressLevel(isAdding: true);
      }
      saveChanges();
    }
  }

  changeStressLevel({bool isAdding = true}) {
    if (isAdding) {
      stressLevel = min(stressLevel + 1, 3);
    } else {
      stressLevel = max(stressLevel - 1, 0);
    }
    notifyListeners();
  }

  changeEffortPoints({bool isAdding = true}) {
    if (isAdding) {
      effortPoints = min(effortPoints + 1, 2);
    } else {
      effortPoints = max(effortPoints - 1, -1);
    }
    notifyListeners();
  }

  int getAptidaoMaxByLevel() {
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

  int getTreinamentoMaxByLevel() {
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

  void changeModGlobal({bool isAdding = true}) {
    if (isAdding) {
      modGlobalTrain++;
    } else {
      modGlobalTrain--;
    }

    notifyListeners();
  }

  onItemsButtonClicked(BuildContext context) async {
    final shoppingViewModel = Provider.of<ShoppingViewModel>(
      context,
      listen: false,
    );
    shoppingViewModel.openInventory(listSheetItems);
    await showShoppingDialog(context);
  }

  void toggleKeepingGlobalModifier() {
    isKeepingGlobalModifier = !isKeepingGlobalModifier;
    notifyListeners();
  }

  String getHelperText(ActionTemplate action) {
    int trainingLevel = listActionValue
        .firstWhere(
          (ActionValue actionValue) => actionValue.actionId == action.id,
          orElse: () => ActionValue(actionId: "", value: 1),
        )
        .value;

    if (action.isFree) {
      return "Ação Livre: a ação acontece instantaneamente.";
    } else if (action.isPreparation) {
      return "Ação de Preparação: uma ação livre que exige Esforço.";
    } else {
      if (action.isResisted) {
        String result =
            "Teste Resistido: conte os sucessos DT10 baseado no seu treinamento.";
        if (trainingLevel <= 1) {
          result +=
              "\nComo seu treinamento é '${getTrainingLevel(trainingLevel)}', apenas o menor dado será considerado para o teste contra a DT10.";
        }
        return result;
      } else {
        String result =
            "Teste de Dificuldade: pegue um número baseado no seu treinamento.";
        if (trainingLevel <= 1) {
          result +=
              "\nComo seu treinamento é '${getTrainingLevel(trainingLevel)}', pegue o menor dado.";
        } else {
          result +=
              "\nComo seu treinamento é '${getTrainingLevel(trainingLevel)}', pegue o maior dado.";
        }
        return result;
      }
    }
  }

  String getTrainingLevel(int ac) {
    switch (ac) {
      case 0:
        return "Aversão";
      case 1:
        return "Sem Aptidão";
      case 2:
        return "Com Aptidão";
      case 3:
        return "Com Treinamento";
      case 4:
        return "Propósito";
      default:
        return "";
    }
  }
}
