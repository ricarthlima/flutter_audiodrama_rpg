import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rpg_audiodrama/data/repositories/action_repository.dart';
import 'package:flutter_rpg_audiodrama/data/repositories/condition_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/services/sheet_service.dart';
import '../../../domain/exceptions/sheet_service_exceptions.dart';
import '../../../domain/models/action_lore.dart';
import '../../../domain/models/action_template.dart';
import '../../../domain/models/action_value.dart';
import '../../../domain/models/roll_log.dart';
import '../../../domain/models/sheet_model.dart';

class SheetViewModel extends ChangeNotifier {
  String id;
  String username;
  bool isWindowed;
  ActionRepository actionRepo;
  ConditionRepository conditionRepo;

  SheetViewModel({
    required this.id,
    required this.username,
    required this.actionRepo,
    required this.conditionRepo,
    this.isWindowed = false,
  });

  SheetService sheetService = SheetService();

  Sheet? sheet;

  // Atributos locais
  int modGlobalTrain = 0;
  bool isKeepingGlobalModifier = false;

  // Outras fichas
  List<Sheet> listSheets = [];

  // Controladores de estado
  bool? _isAuthorized;
  bool? get isAuthorized => _isAuthorized;
  bool _isLoading = true;
  get isLoading => _isLoading;
  bool isFoundSheet = false;
  bool isEditing = false;
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;
  set notificationCount(int value) {
    _notificationCount = value;
    notifyListeners();
  }

  // Objetos externos
  GlobalKey<ExpandableFabState> fabKey = GlobalKey<ExpandableFabState>();
  Future<Sheet?> futureGetSheet = Future.delayed(Duration.zero);
  final TextEditingController nameController = TextEditingController();

  bool? isSavingNotes;
  final TextEditingController _notesTextController = TextEditingController();

  updateCredentials({String? id, String? username}) {
    this.id = id ?? this.id;
    this.username = username ?? this.username;
    isEditing = false;
    notifyListeners();
  }

  closeFab() {
    final state = fabKey.currentState;
    if (state != null) {
      state.toggle();
    }
  }

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

    futureGetSheet = sheetService.getSheetId(id: id, username: username);

    try {
      Sheet? sheetModel = await futureGetSheet;

      if (sheetModel != null) {
        nameController.text = sheetModel.characterName;
        sheet = sheetModel;
        isFoundSheet = true;
      }

      listSheets = await SheetService().getSheetsByUser();
    } on UsernameNotFoundException {
      _isAuthorized = false;
      notifyListeners();
      return;
    } on UserNotAuthorizedOnSheetException {
      _isAuthorized = false;
      notifyListeners();
      return;
    }

    _isAuthorized = true;
    notifyListeners();
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

  Future<Sheet?> saveChanges() async {
    if (sheet != null) {
      if (nameController.text != "") {
        sheet!.characterName = nameController.text;
      }

      await SheetService().saveSheet(sheet!);
    }
    return sheet;
  }

  onActionValueChanged({required ActionValue ac, required bool isWork}) {
    if (sheet == null) return;

    if (!isWork) {
      if (sheet!.listActionValue
          .where((e) => e.actionId == ac.actionId)
          .isNotEmpty) {
        sheet!.listActionValue.removeWhere((e) => e.actionId == ac.actionId);
      }
      sheet!.listActionValue.add(ac);
    } else {
      if (sheet!.listWorks.where((e) => e.actionId == ac.actionId).isNotEmpty) {
        sheet!.listWorks.removeWhere((e) => e.actionId == ac.actionId);
      }
      sheet!.listWorks.add(ac);
    }
    notifyListeners();
  }

  changeStressLevel({bool isAdding = true}) {
    if (sheet == null) return;

    if (isAdding) {
      sheet!.stressLevel = min(sheet!.stressLevel + 1, 3);
    } else {
      sheet!.stressLevel = max(sheet!.stressLevel - 1, 0);
    }
    notifyListeners();

    if (isWindowed) {
      saveChanges();
    }
  }

  changeEffortPoints({bool isAdding = true}) {
    if (sheet == null) return;

    if (isAdding) {
      sheet!.effortPoints = min(sheet!.effortPoints + 1, 2);
    } else {
      sheet!.effortPoints = max(sheet!.effortPoints - 1, -1);
    }
    notifyListeners();

    if (isWindowed) {
      saveChanges();
    }
  }

  int getAptidaoMaxByLevel() {
    switch (sheet!.baseLevel) {
      case 0:
        return 8;
      case 1:
        return 15;
      case 2:
        return 20;
      case 3:
        return 25;
    }
    return -1;
  }

  int getTreinamentoMaxByLevel() {
    switch (sheet!.baseLevel) {
      case 0:
        return 2;
      case 1:
        return 5;
      case 2:
        return 10;
      case 3:
        return 15;
    }
    return -1;
  }

  void changeModGlobal({bool isAdding = true}) {
    if (isAdding) {
      modGlobalTrain++;
    } else {
      modGlobalTrain--;
    }

    notifyListeners();
  }

  void toggleKeepingGlobalModifier() {
    isKeepingGlobalModifier = !isKeepingGlobalModifier;
    notifyListeners();
  }

  String getHelperText(ActionTemplate action) {
    int trainingLevel = sheet!.listActionValue
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
    int totalProposito =
        getActionsValuesWithWorks().where((e) => e.value == 4).length;
    int totalAversao =
        getActionsValuesWithWorks().where((e) => e.value == 0).length;

    return (totalProposito * 3) - totalAversao;
  }

  String getTrainLevelByActionName(String actionId) {
    return getTrainingLevel(getActionsValuesWithWorks()
        .firstWhere((e) => e.actionId == actionId,
            orElse: () => ActionValue(actionId: actionId, value: 1))
        .value);
  }

  int getTrainLevelByAction(String actionId) {
    List<ActionValue> listFromBaseActions = sheet!.listActionValue
        .where(
          (e) => e.actionId == actionId,
        )
        .toList();

    if (listFromBaseActions.isNotEmpty) {
      return listFromBaseActions[0].value;
    }

    List<ActionValue> listFromWorks = sheet!.listWorks
        .where(
          (e) => e.actionId == actionId,
        )
        .toList();

    if (listFromWorks.isNotEmpty) {
      return listFromWorks[0].value;
    }

    return 1;
  }

  Future<void> toggleActiveWork(String id) async {
    if (sheet!.listActiveWorks.contains(id)) {
      sheet!.listActiveWorks.remove(id);
    } else {
      sheet!.listActiveWorks.add(id);
    }
    await saveChanges();
    notifyListeners();
  }

  void saveActionLore(
      {required String actionId, required String loreText}) async {
    if (sheet!.listActionLore.where((e) => e.actionId == actionId).isNotEmpty) {
      int index =
          sheet!.listActionLore.indexWhere((e) => e.actionId == actionId);
      sheet!.listActionLore[index].loreText = loreText;
    } else {
      sheet!.listActionLore
          .add(ActionLore(actionId: actionId, loreText: loreText));
    }
    saveChanges();
    notifyListeners();
  }

  TextEditingController notesTextController() {
    _notesTextController.text = sheet!.notes;
    return _notesTextController;
  }

  void saveNotes() async {
    sheet!.notes = _notesTextController.text;
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
    _bioEditingController.text = sheet!.bio;
    return _bioEditingController;
  }

  void saveBio() async {
    sheet!.bio = _bioEditingController.text;
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
    return sheet!.listActiveConditions.contains(id);
  }

  toggleCondition(String id) {
    if (sheet!.listActiveConditions.contains(id)) {
      sheet!.listActiveConditions.remove(id);
    } else {
      sheet!.listActiveConditions.add(id);
    }
    saveChanges();
    notifyListeners();
  }

  String getMajorCondition() {
    String result = "DESPERTO";

    if (sheet!.listActiveConditions.isNotEmpty) {
      sheet!.listActiveConditions.sort(
        (a, b) {
          int showA = conditionRepo.getConditionById(a)!.showingOrder;
          int showB = conditionRepo.getConditionById(b)!.showingOrder;

          return showA.compareTo(showB);
        },
      );

      String idMajor = sheet!.listActiveConditions.last;
      return conditionRepo.getConditionById(idMajor)!.name.toUpperCase();
    }

    return result;
  }

  onUploadBioImageClicked(XFile image) async {
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

      sheet!.imageUrl = path;

      notifyListeners();
      saveChanges();
    }
  }

  onRemoveImageClicked() async {
    if (sheet!.imageUrl == null) return;

    String fileName = sheet!.imageUrl!.split("/").last;

    await sheetService.deleteBioImage(fileName);
    sheet!.imageUrl = null;

    notifyListeners();
    saveChanges();
  }

  List<ActionValue> getActionsValuesWithWorks() {
    // TODO: A enebalcencia da action devia ser por campanha
    List<ActionValue> listAC = sheet!.listActionValue.map((e) => e).toList() +
        sheet!.listWorks.map((e) => e).toList();

    List<String> listAllEnabled = actionRepo
        .getAllActions()
        .where((e) => e.enabled)
        .toList()
        .map((e) => e.id)
        .toList();

    listAC.removeWhere((e) => !listAllEnabled.contains(e.actionId));

    return listAC;
  }

  void addTextToEndActionValues() {
    String result = "\n";
    List<ActionTemplate> listActions = getActionsValuesWithWorks()
        .map((e) => actionRepo.getActionById(e.actionId)!)
        .toList();
    for (ActionTemplate action in listActions) {
      result +=
          "## ${getTrainLevelByActionName(action.id)} em ${action.name}\n";
      if (sheet!.listActionLore
          .where((e) => e.actionId == action.id)
          .isNotEmpty) {
        result += sheet!.listActionLore
            .firstWhere((e) => e.actionId == action.id)
            .loreText;
      }
      result += "\n\n";
    }
    sheet!.bio += result;
    notifyListeners();
  }

  bool get isOwner {
    return sheet!.ownerId == FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> onRoll({required RollLog roll}) async {
    ActionTemplate? action = actionRepo.getActionById(roll.idAction);

    sheet!.listRollLog.add(roll);
    await saveChanges();
    notificationCount++;

    if (!isKeepingGlobalModifier) {
      modGlobalTrain = 0;
    }

    notifyListeners();

    if (action != null && action.isPreparation) {
      sheet!.effortPoints++;
      if (sheet!.effortPoints >= 2) {
        sheet!.effortPoints = -1;
        changeStressLevel(isAdding: true);
      }
      saveChanges();
    }
  }
}
