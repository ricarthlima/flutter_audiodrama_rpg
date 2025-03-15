import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:flutter_rpg_audiodrama/ui/sheet/components/roll_body_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_works_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet_notes/sheet_notes.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/statistics_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/view/statistics_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/daos/action_dao.dart';
import '../../../domain/exceptions/sheet_service_exceptions.dart';
import '../../../domain/models/action_template.dart';
import '../../../domain/models/item_sheet.dart';
import '../../../domain/models/sheet_model.dart';
import '../../shopping/shopping_screen.dart';
import '../components/action_dialog_tooltip.dart';
import '../components/roll_dialog.dart';

class SheetViewModel extends ChangeNotifier {
  String id;
  String username;

  SheetViewModel({required this.id, required this.username});
  SheetService sheetService = SheetService();

  // Atributos de ficha
  String characterName = "";
  int stressLevel = 0;
  int effortPoints = -1;
  List<ActionValue> listActionValue = [];
  List<RollLog> listRollLog = [];
  int baseLevel = 0;
  List<ItemSheet> listSheetItems = [];
  double money = 0;
  double weight = 0;
  List<ActionLore> listActionLore = [];
  String bio = "";
  String notes = "";
  List<String> listActiveConditions = [];
  String? imageUrl;
  List<ActionValue> listWorks = [];
  String? campaignId;
  List<String> listSharedIds = [];
  String _ownerId = "";
  String get ownerId => _ownerId;

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

  updateCredentials({String? id, String? username}) {
    this.id = id ?? this.id;
    this.username = username ?? this.username;
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
        characterName = sheetModel.characterName;
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
        listWorks = sheetModel.listWorks;
        campaignId = sheetModel.campaignId;
        listSharedIds = sheetModel.listSharedIds;
        _ownerId = sheetModel.ownerId;

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

  Future<void> saveChanges() async {
    Sheet sheet = Sheet(
      id: id,
      characterName:
          (nameController.text != "") ? nameController.text : characterName,
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
      listWorks: listWorks,
      listSharedIds: listSharedIds,
      campaignId: campaignId,
      ownerId: _ownerId,
    );
    // Beleza, mas você colocou também no refresh?

    await SheetService().saveSheet(sheet);
  }

  onActionValueChanged({required ActionValue ac, required bool isWork}) {
    if (!isWork) {
      if (listActionValue.where((e) => e.actionId == ac.actionId).isNotEmpty) {
        listActionValue.removeWhere((e) => e.actionId == ac.actionId);
      }
      listActionValue.add(ac);
    } else {
      if (listWorks.where((e) => e.actionId == ac.actionId).isNotEmpty) {
        listWorks.removeWhere((e) => e.actionId == ac.actionId);
      }
      listWorks.add(ac);
    }
    notifyListeners();
  }

  onRoll(BuildContext context, {required RollLog roll}) async {
    ActionTemplate? action = ActionDAO.instance.getActionById(roll.idAction);

    if (!ActionDAO.instance.isOnlyFreeOrPreparation(roll.idAction) ||
        ActionDAO.instance.isLuckAction(roll.idAction)) {
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

  onRollBodyDice({required BuildContext context, required bool isSerious}) {
    int roll = Random().nextInt(6) + 1;
    showRollBodyDialog(context: context, roll: roll, isSerious: isSerious);
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
    int totalProposito =
        getActionsValuesWithWorks().where((e) => e.value == 4).length;
    int totalAversao =
        getActionsValuesWithWorks().where((e) => e.value == 0).length;

    return (totalProposito * 3) - totalAversao;
  }

  String getTrainLevelByActionName(String actionId) {
    return getTrainingLevel(listActionValue
        .firstWhere((e) => e.actionId == actionId,
            orElse: () => ActionValue(actionId: actionId, value: 1))
        .value);
  }

  int getTrainLevelByAction(String actionId) {
    List<ActionValue> listFromBaseActions = listActionValue
        .where(
          (e) => e.actionId == actionId,
        )
        .toList();

    if (listFromBaseActions.isNotEmpty) {
      return listFromBaseActions[0].value;
    }

    List<ActionValue> listFromWorks = listWorks
        .where(
          (e) => e.actionId == actionId,
        )
        .toList();

    if (listFromWorks.isNotEmpty) {
      return listFromWorks[0].value;
    }

    return 1;
  }

  List<String> getWorkIds() {
    List<String> result = [];
    for (ActionValue ac in listWorks) {
      ActionTemplate action = ActionDAO.instance.getActionById(ac.actionId)!;
      if (!result.contains(action.work)) {
        result.add(action.work ?? "");
      }
    }
    return result;
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

  void onWorksButtonClicked(BuildContext context) async {
    if (!isVertical(context)) {
      await showSheetWorksDialog(context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetWorksDialog(),
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

  List<ActionValue> getActionsValuesWithWorks() {
    return listActionValue.map((e) => e).toList() +
        listWorks.map((e) => e).toList();
  }

  bool get isOwner {
    return ownerId == FirebaseAuth.instance.currentUser!.uid;
  }
}
