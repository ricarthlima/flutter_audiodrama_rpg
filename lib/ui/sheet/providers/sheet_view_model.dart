import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rpg_audiodrama/domain/dto/spell.dart';
import 'package:flutter_rpg_audiodrama/domain/models/item_sheet.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_custom_count.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/constants/roll_type.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/models/group_action.dart';

import '../../../data/modules.dart';
import '../../../data/repositories/action_repository.dart';
// import '../../../data/repositories/condition_repository.dart';
import '../../../data/repositories/spell_repository.dart';
import '../../../data/services/sheet_service.dart';
import '../../../domain/dto/action_template.dart';
import '../../../domain/dto/item.dart';
import '../../../domain/exceptions/sheet_service_exceptions.dart';
import '../../../domain/models/action_lore.dart';
import '../../../domain/models/action_value.dart';
import '../../../domain/models/campaign.dart';
import '../../../domain/models/roll_log.dart';
import '../../../domain/models/sheet_model.dart';
import '../helpers/sheet_subpages.dart';

class SheetViewModel extends ChangeNotifier {
  String id;
  String username;
  bool isWindowed;
  ActionRepository actionRepo;
  SpellRepository spellRepo;
  // ConditionRepository conditionRepo;

  SheetViewModel({
    required this.id,
    required this.username,
    required this.actionRepo,
    required this.spellRepo,
    this.isWindowed = false,
  });

  SheetService sheetService = SheetService();

  Sheet? sheet;

  // Atributos locais
  List<RollLog> currentRollLog = [];
  ActionTemplate? showingRollTip;
  ActionTemplate? showingActionTip;
  ActionTemplate? showingActionLore;
  bool showingUpinsertItemDialog = false;
  Item? showingUpinsertItem;

  // Outras fichas
  List<Sheet> listSheets = [];

  // Sub páginas
  SheetSubpages _currentPage = SheetSubpages.sheet;
  SheetSubpages get currentPage => _currentPage;
  set currentPage(SheetSubpages value) {
    _currentPage = value;
    notifyListeners();
  }

  // Controladores de estado
  bool? _isAuthorized;
  bool? get isAuthorized => _isAuthorized;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
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

  void updateCredentials({String? id, String? username}) {
    this.id = id ?? this.id;
    this.username = username ?? this.username;
    isEditing = false;
    notifyListeners();
  }

  // void _safeNotify() {
  //   final phase = SchedulerBinding.instance.schedulerPhase;
  //   if (phase == SchedulerPhase.idle ||
  //       phase == SchedulerPhase.postFrameCallbacks) {
  //     notifyListeners();
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  //   }
  // }

  void closeFab() {
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

    futureGetSheet = sheetService.getSheetById(id: id, username: username);

    try {
      Sheet? sheetModel = await futureGetSheet;

      if (sheetModel != null) {
        nameController.text = sheetModel.characterName;
        sheet = sheetModel;
        isFoundSheet = true;
        _loadActionGroup();
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

  void onActionValueChanged({required ActionValue ac, required bool isWork}) {
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

  void changeStressPoints({bool isAdding = true}) {
    if (sheet == null) return;

    if (isAdding) {
      sheet!.stressPoints = min(sheet!.stressPoints + 1, 15);
    } else {
      sheet!.stressPoints = max(sheet!.stressPoints - 1, 0);
    }

    scheduleSave();
  }

  void changeExhaustPoints({bool isAdding = true}) {
    if (sheet == null) return;

    if (isAdding) {
      sheet!.exhaustPoints = min(sheet!.exhaustPoints + 1, 15);
    } else {
      sheet!.exhaustPoints = max(sheet!.exhaustPoints - 1, 0);
    }

    scheduleSave();
  }

  Timer? schSaveTimer;

  void scheduleSave() {
    notifyListeners();

    if (schSaveTimer != null) {
      schSaveTimer!.cancel();
      schSaveTimer = null;
    }
    schSaveTimer = Timer(Duration(seconds: 2), () {
      saveChanges();
    });
  }

  void restShort() {
    sheet!.stressPoints = max(0, sheet!.stressPoints - 3);
    sheet!.exhaustPoints = max(0, sheet!.exhaustPoints - 3);

    if (customCount(energySpellModuleSCC) != null &&
        sheet!.booleans["hasShortRested"] != true) {
      _recoverEnergy(half: true);
    }

    sheet!.booleans["hasShortRested"] = true;

    scheduleSave();
  }

  void restLong() {
    sheet!.stressPoints = max(0, sheet!.stressPoints - 6);
    sheet!.exhaustPoints = 0;

    if (customCount(energySpellModuleSCC) != null) {
      _recoverEnergy();
    }

    sheet!.booleans["hasShortRested"] = false;

    scheduleSave();
  }

  void _recoverEnergy({bool half = false}) {
    int maxToRecover = 0;
    switch (sheet!.baseLevel) {
      case 0:
        maxToRecover = 6;
      case 1:
        maxToRecover = 12;
      case 2:
        maxToRecover = 18;
      case 3:
        maxToRecover = 27;
    }
    int amountToRecover = maxToRecover;
    if (half) {
      amountToRecover = amountToRecover ~/ 2;
    }
    customCount(energySpellModuleSCC)!.count = min(
      maxToRecover,
      customCount(energySpellModuleSCC)!.count + amountToRecover,
    );
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

  String getHelperText(ActionTemplate action, RollType rollType) {
    int trainingLevel = sheet!.listActionValue
        .firstWhere(
          (ActionValue actionValue) => actionValue.actionId == action.id,
          orElse: () => ActionValue(actionId: "", value: 1),
        )
        .value;

    switch (rollType) {
      case RollType.free:
        return "Ação Livre: a ação acontece instantaneamente.";
      case RollType.prepared:
        return "Ação de Preparação: uma ação livre que exige Esforço.";
      case RollType.resisted:
        String result =
            "Teste Resistido\nConte os sucessos DT10 baseado no seu treinamento.";
        if (trainingLevel <= 1) {
          result +=
              "\nComo seu treinamento é '${getTrainingLevel(trainingLevel)}', apenas o menor dado será considerado para o teste contra a DT10.";
        }
        return result;
      case RollType.difficult:
        String result =
            "Teste de Dificuldade"; //\nPegue um número baseado no seu treinamento.";
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
    int totalProposito = getActionsValuesWithWorks()
        .where((e) => e.value == 4)
        .length;
    int totalAversao = getActionsValuesWithWorks()
        .where((e) => e.value == 0)
        .length;

    return (totalProposito * 3) - totalAversao;
  }

  String getTrainLevelByActionName(String actionId) {
    return getTrainingLevel(
      getActionsValuesWithWorks()
          .firstWhere(
            (e) => e.actionId == actionId,
            orElse: () => ActionValue(actionId: actionId, value: 1),
          )
          .value,
    );
  }

  int getTrainLevelByAction(String actionId) {
    List<ActionValue> listFromBaseActions = sheet!.listActionValue
        .where((e) => e.actionId == actionId)
        .toList();

    if (listFromBaseActions.isNotEmpty) {
      return listFromBaseActions[0].value;
    }

    List<ActionValue> listFromWorks = sheet!.listWorks
        .where((e) => e.actionId == actionId)
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

    scheduleSave();
  }

  Future<void> toggleActiveModule(String id) async {
    if (sheet!.listActiveModules.contains(id)) {
      sheet!.listActiveModules.remove(id);
    } else {
      sheet!.listActiveModules.add(id);
    }
    scheduleSave();
  }

  bool isModuleActive({required String moduleId, Campaign? campaign}) {
    if (campaign == null) {
      return sheet!.listActiveModules.contains(moduleId);
    } else {
      return campaign.campaignSheetSettings.listActiveModuleIds.contains(
        moduleId,
      );
    }
  }

  void saveActionLore({
    required String actionId,
    required String loreText,
  }) async {
    if (sheet!.listActionLore.where((e) => e.actionId == actionId).isNotEmpty) {
      int index = sheet!.listActionLore.indexWhere(
        (e) => e.actionId == actionId,
      );
      sheet!.listActionLore[index].loreText = loreText;
    } else {
      sheet!.listActionLore.add(
        ActionLore(actionId: actionId, loreText: loreText),
      );
    }
    scheduleSave();
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

  void addCondition() {
    if (sheet!.condition < 4) {
      sheet!.condition = sheet!.condition + 1;
      scheduleSave();
    }
  }

  void removeCondition() {
    if (sheet!.condition > 0) {
      sheet!.condition = sheet!.condition - 1;
      scheduleSave();
    }
  }

  // bool getHasCondition(String id) {
  //   return sheet!.listActiveConditions.contains(id);
  // }

  // toggleCondition(String id) {
  //   if (sheet!.listActiveConditions.contains(id)) {
  //     sheet!.listActiveConditions.remove(id);
  //   } else {
  //     sheet!.listActiveConditions.add(id);
  //   }
  //   saveChanges();
  //   notifyListeners();
  // }

  // String getMajorCondition() {
  //   String result = "DESPERTO";

  //   if (sheet!.listActiveConditions.isNotEmpty) {
  //     sheet!.listActiveConditions.sort(
  //       (a, b) {
  //         int showA = conditionRepo.getConditionById(a)!.showingOrder;
  //         int showB = conditionRepo.getConditionById(b)!.showingOrder;

  //         return showA.compareTo(showB);
  //       },
  //     );

  //     String idMajor = sheet!.listActiveConditions.last;
  //     return conditionRepo.getConditionById(idMajor)!.name.toUpperCase();
  //   }

  //   return result;
  // }

  Future<void> onUploadBioImageClicked(Uint8List image) async {
    _isLoading = true;
    notifyListeners();

    String? path = await sheetService.uploadBioImage(
      bytes: image,
      sheetId: sheet!.id,
    );

    _isLoading = false;
    notifyListeners();

    sheet!.imageUrl = path;

    scheduleSave();
  }

  Future<void> onRemoveImageClicked() async {
    if (sheet!.imageUrl == null) return;
    await sheetService.deleteBioImage(sheetId: sheet!.id);
    sheet!.imageUrl = null;

    scheduleSave();
  }

  List<ActionValue> getActionsValuesWithWorks() {
    // TODO: A enebalcencia da action devia ser por campanha
    List<ActionValue> listAC =
        sheet!.listActionValue.map((e) => e).toList() +
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

  Future<void> onRoll({required RollLog roll, required String groupId}) async {
    ActionTemplate? action = actionRepo.getActionById(roll.idAction);

    sheet!.listRollLog.add(roll);
    notificationCount++;

    if (!mapGroupAction[groupId]!.holdMod) {
      mapGroupAction[groupId]!.mod = 0;
    }

    if (action != null && action.isPreparation) {
      sheet!.stressPoints++;
    }

    if (!actionRepo.isOnlyFreeOrPreparation(roll.idAction) ||
        actionRepo.isLuckAction(roll.idAction)) {
      currentRollLog.add(roll);
    } else {
      showingRollTip = action;
    }

    scheduleSave();
  }

  void showActionTip(ActionTemplate action) {
    showingActionTip = action;
    notifyListeners();
  }

  void showActionLore(ActionTemplate action) {
    showingActionLore = action;
    notifyListeners();
  }

  void showItemDialog({Item? item}) {
    showingUpinsertItem = item;
    showingUpinsertItemDialog = true;
    notifyListeners();
  }

  void onStackDialogDismiss() {
    currentRollLog = [];
    showingRollTip = null;
    showingActionTip = null;
    showingActionLore = null;
    showingUpinsertItemDialog = false;
    notifyListeners();
  }

  Map<String, GroupAction> mapGroupAction = {
    GroupActionIds.basic: GroupAction(
      id: GroupActionIds.basic,
      mod: 0,
      holdMod: false,
      listActions: [],
    ),
    GroupActionIds.resisted: GroupAction(
      id: GroupActionIds.resisted,
      mod: 0,
      holdMod: false,
      listActions: [],
    ),
    GroupActionIds.strength: GroupAction(
      id: GroupActionIds.strength,
      mod: 0,
      holdMod: false,
      listActions: [],
    ),
    GroupActionIds.agility: GroupAction(
      id: GroupActionIds.agility,
      mod: 0,
      holdMod: false,
      listActions: [],
    ),
    GroupActionIds.intellect: GroupAction(
      id: GroupActionIds.intellect,
      mod: 0,
      holdMod: false,
      listActions: [],
    ),
    GroupActionIds.social: GroupAction(
      id: GroupActionIds.social,
      mod: 0,
      holdMod: false,
      listActions: [],
    ),
  };

  void _loadActionGroup() {
    mapGroupAction[GroupActionIds.basic]!.listActions = actionRepo.getBasics();
    mapGroupAction[GroupActionIds.resisted]!.listActions = actionRepo
        .getResisted();
    mapGroupAction[GroupActionIds.strength]!.listActions = actionRepo
        .getStrength();
    mapGroupAction[GroupActionIds.agility]!.listActions = actionRepo
        .getAgility();
    mapGroupAction[GroupActionIds.intellect]!.listActions = actionRepo
        .getIntellect();
    mapGroupAction[GroupActionIds.social]!.listActions = actionRepo.getSocial();

    for (String key in actionRepo.getListWorks().map((e) => e.name)) {
      if (mapGroupAction[key] == null) {
        mapGroupAction[key] = GroupAction(
          id: key,
          mod: 0,
          holdMod: false,
          listActions: actionRepo.getActionsByGroupName(key),
          isWork: true,
        );
      }
    }
  }

  void changeModGroup({required String id, required bool isAdding}) {
    if (isAdding) {
      mapGroupAction[id]!.mod++;
    } else {
      mapGroupAction[id]!.mod--;
    }
    notifyListeners();
  }

  void toggleModHold({required String id}) {
    mapGroupAction[id]!.holdMod = !mapGroupAction[id]!.holdMod;
    notifyListeners();
  }

  int modValueGroup(String id) {
    return mapGroupAction[id]!.mod;
  }

  bool modHoldGroup(String id) {
    return mapGroupAction[id]!.holdMod;
  }

  String? groupByAction(String actionId) {
    for (String key in mapGroupAction.keys) {
      final query = mapGroupAction[key]!.listActions.where(
        (e) => e.id == actionId,
      );
      if (query.isEmpty) {
        return key;
      }
    }
    return null;
  }

  void addSpell(Spell data) {
    if (sheet!.listSpell.contains(data.id)) return;
    sheet!.listSpell.add(data.id);
    notifyListeners();
  }

  void removeSpell(Spell data) {
    if (!sheet!.listSpell.contains(data.id)) return;
    sheet!.listSpell.remove(data.id);
    notifyListeners();
  }

  bool showMagicModule(Campaign? campaign) {
    return (campaign != null &&
            campaign.campaignSheetSettings.listActiveModuleIds.contains(
              Module.magic.id,
            )) ||
        (campaign == null &&
            sheet!.listActiveModules.contains(Module.magic.id));
  }

  SheetCustomCount? customCount(String idd) {
    Iterable<SheetCustomCount> query = sheet!.listCustomCount.where(
      (e) => e.id == idd,
    );

    if (query.isNotEmpty) {
      return query.first;
    }

    return null;
  }

  void customCountAdd(String idd) {
    Iterable<SheetCustomCount> query = sheet!.listCustomCount.where(
      (e) => e.id == idd,
    );
    if (query.isEmpty) {
      sheet!.listCustomCount.add(
        SheetCustomCount(id: idd, name: "", description: "", count: 1),
      );
    } else {
      query.first.count += 1;
    }

    scheduleSave();
  }

  void customCountRemove(String idd) {
    Iterable<SheetCustomCount> query = sheet!.listCustomCount.where(
      (e) => e.id == idd,
    );

    if (query.isNotEmpty) {
      query.first.count -= 1;
    } else {
      sheet!.listCustomCount.add(
        SheetCustomCount(id: idd, name: "", description: "", count: -1),
      );
    }

    scheduleSave();
  }

  void customCountInsert(SheetCustomCount value) {
    int index = sheet!.listCustomCount.indexWhere((e) => e.id == value.id);

    if (index != -1) {
      sheet!.listCustomCount[index] = value;
    } else {
      sheet!.listCustomCount.add(value);
    }

    scheduleSave();
  }

  void customCountDelete(String idd) {
    sheet!.listCustomCount.removeWhere((e) => e.id == idd);

    scheduleSave();
  }

  bool consumeEnergy(int energy) {
    bool needToExhaust = false;
    if (customCount(energySpellModuleSCC) != null) {
      if (customCount(energySpellModuleSCC)!.count < energy) {
        needToExhaust = true;
      }
      customCount(energySpellModuleSCC)!.count -= energy;
    } else {
      needToExhaust = true;
      sheet!.listCustomCount.add(
        SheetCustomCount(
          id: energySpellModuleSCC,
          name: "energy",
          description: "",
          count: energy * -1,
        ),
      );
    }
    if (needToExhaust) {
      if (sheet!.exhaustPoints <= 11) {
        sheet!.exhaustPoints += 4;
        scheduleSave();
        return true;
      } else {
        return false;
      }
    } else {
      scheduleSave();
      return true;
    }
  }

  bool get isShowingRolls => getBoolean("IS_SHOWING_ROLLS");
  set isShowingRolls(bool value) => setBoolean("IS_SHOWING_ROLLS", value);

  bool getBoolean(String idd) {
    return sheet!.booleans[idd] ?? false;
  }

  void setBoolean(String idd, bool value) {
    sheet!.booleans[idd] = value;
    scheduleSave();
  }

  void setTokenIndex(int value) {
    sheet!.indexToken = value;
    scheduleSave();
  }

  void uploadToken({required Uint8List image, required int index}) async {
    String url = await SheetService().uploadTokenImage(
      image: image,
      sheetId: sheet!.id,
      index: index,
    );

    if (index < sheet!.listTokens.length) {
      sheet!.listTokens[index] = url;
    } else {
      sheet!.listTokens.add(url);
    }

    scheduleSave();
  }

  void removeToken(int index) {
    if (sheet!.indexToken >= index && index != 0) {
      sheet!.indexToken -= 1;
    }

    sheet!.listTokens.removeAt(index);
    SheetService().deleteTokenImage(index: index, sheetId: sheet!.id);

    scheduleSave();
  }

  void upinsertCustomItem(Item item, int amount) {
    int index = sheet!.listCustomItems.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      sheet!.listCustomItems[index] = item;
    } else {
      sheet!.listCustomItems.add(item);
      sheet!.listItemSheet.add(ItemSheet(itemId: item.id, uses: 0, amount: 1));
    }
    scheduleSave();
  }
}
