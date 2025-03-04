import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rpg_audiodrama/data/daos/condition_dao.dart';
import 'package:flutter_rpg_audiodrama/data/services/sheet_service.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_lore.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_value.dart';
import 'package:flutter_rpg_audiodrama/domain/models/roll_log.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/conditions_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet_notes/sheet_notes.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/statistics_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/view/statistics_view_model.dart';
import 'package:image_picker/image_picker.dart';
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
  List<ActionLore> listActionLore = [];

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
  String bio = "";
  String notes = "";
  List<String> listActiveConditions = [];
  String? imageUrl;

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
      sheet = sheetModel;

      listActionValue = sheetModel.listActionValue;
      listRollLog = sheetModel.listRollLog;
      effortPoints = sheetModel.effortPoints;
      stressLevel = sheetModel.stressLevel;
      baseLevel = sheetModel.baseLevel;
      listSheetItems = sheetModel.listItemSheet;
      money = sheetModel.money;
      weight = sheetModel.weight;
      listActionLore = sheetModel.listActionLore;
      bio = sheetModel.bio;
      notes = sheetModel.notes;
      listActiveConditions = sheetModel.listActiveConditions;
      imageUrl = sheetModel.imageUrl;
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
      listActionLore: listActionLore,
      bio: bio,
      notes: notes,
      listActiveConditions: listActiveConditions,
      imageUrl: imageUrl,
    );
    // Beleza, mas você colocou também no refresh?

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

    if (!isVertical(context)) {
      await showShoppingDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingDialogScreen(),
        ),
      );
    }
  }

  onConditionButtonClicked(BuildContext context) async {
    await showSheetConditionsDialog(context);
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

  int getPropositoMinusAversao() {
    int totalProposito = listActionValue.where((e) => e.value == 4).length;
    int totalAversao = listActionValue.where((e) => e.value == 0).length;

    return (totalProposito * 3) - totalAversao;
  }

  String getTrainLevelByActionName(String actionId) {
    return getTrainingLevel(listActionValue
        .firstWhere((e) => e.actionId == actionId,
            orElse: () => ActionValue(actionId: actionId, value: 1))
        .value);
  }

  int getTrainLevelByAction(String actionId) {
    return listActionValue
        .firstWhere((e) => e.actionId == actionId,
            orElse: () => ActionValue(actionId: actionId, value: 1))
        .value;
  }

  void saveActionLore(
      {required String actionId, required String loreText}) async {
    if (listActionLore.where((e) => e.actionId == actionId).isNotEmpty) {
      int index = listActionLore.indexWhere((e) => e.actionId == actionId);
      listActionLore[index].loreText = loreText;
    } else {
      listActionLore.add(ActionLore(actionId: actionId, loreText: loreText));
    }
    saveChanges();
    notifyListeners();
  }

  onNotesButtonClicked(BuildContext context) async {
    if (!isVertical(context)) {
      await showSheetNotesDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetNotesScreen(),
        ),
      );
    }
  }

  onStatisticsButtonClicked(BuildContext context) async {
    context.read<StatisticsViewModel>().listCompleteRollLog = listRollLog;

    if (!isVertical(context)) {
      await showSheetStatisticsDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetStatisticsScreen(),
        ),
      );
    }
  }

  bool? isSavingNotes;
  final TextEditingController _notesTextController = TextEditingController();

  TextEditingController notesTextController() {
    _notesTextController.text = notes;
    return _notesTextController;
  }

  void saveNotes() async {
    notes = _notesTextController.text;
    notifyListeners();

    isSavingNotes = true;
    notifyListeners();

    await saveChanges();
    isSavingNotes = false;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 2000));
    isSavingNotes = null;
    notifyListeners();
  }

  bool? isSavingBio;
  final TextEditingController _bioEditingController = TextEditingController();

  TextEditingController bioEditingController() {
    _bioEditingController.text = bio;
    return _bioEditingController;
  }

  void saveBio() async {
    bio = _bioEditingController.text;
    notifyListeners();

    isSavingBio = true;
    notifyListeners();

    await saveChanges();
    isSavingBio = false;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 2000));
    isSavingBio = null;
    notifyListeners();
  }

  bool getHasCondition(String id) {
    return listActiveConditions.contains(id);
  }

  toggleCondition(String id) {
    if (listActiveConditions.contains(id)) {
      listActiveConditions.remove(id);
    } else {
      listActiveConditions.add(id);
    }
    saveChanges();
    notifyListeners();
  }

  String getMajorCondition() {
    String result = "DESPERTO";

    if (listActiveConditions.isNotEmpty) {
      listActiveConditions.sort(
        (a, b) {
          int showA = ConditionDAO.instance.getConditionById(a)!.showingOrder;
          int showB = ConditionDAO.instance.getConditionById(b)!.showingOrder;

          return showA.compareTo(showB);
        },
      );

      String idMajor = listActiveConditions.last;
      return ConditionDAO.instance
          .getConditionById(idMajor)!
          .name
          .toUpperCase();
    }

    return result;
  }

  onUploadBioImageClicked(BuildContext context) async {
    ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );

    if (image != null) {
      int sizeInBytes = await image.length();

      if (sizeInBytes >= 2000000) {
        //TODO: Sua imagem é muito pesada.
      } else {
        String? path;
        if (!kIsWeb) {
          path = await sheetService.uploadBioImage(
            File(image.path),
            "${DateTime.now().millisecondsSinceEpoch}-$id.${image.name.split(".").last}",
          );
        } else {
          Uint8List bytes = await image.readAsBytes();
          path = await sheetService.uploadBioImageBytes(
            bytes,
            "${DateTime.now().millisecondsSinceEpoch}-$id.${image.name.split(".").last}",
          );
        }

        imageUrl = path;

        notifyListeners();
        saveChanges();
      }
    }
  }

  onRemoveImageClicked() async {
    if (imageUrl == null) return;

    String fileName = imageUrl!.split("/").last;

    await sheetService.deleteBioImage(fileName);
    imageUrl = null;

    notifyListeners();
    saveChanges();
  }
}
