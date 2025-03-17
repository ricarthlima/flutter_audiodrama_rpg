import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rpg_audiodrama/domain/models/action_template.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_value.dart';
import 'package:flutter_rpg_audiodrama/domain/models/list_action.dart';

class ActionDAO {
  ActionDAO._();
  static final ActionDAO _instance = ActionDAO._();
  static ActionDAO get instance {
    return _instance;
  }

  List<ListAction> listListActions = [];

  Future<void> initialize() async {
    String jsonString =
        await rootBundle.loadString('assets/sheets/acoes-0.0.6.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    for (String key in jsonData.keys) {
      String name = key;
      bool isWork = (jsonData[key] as List<dynamic>).first["isWork"];
      List<ActionTemplate> listAc = (jsonData[key] as List<dynamic>)
          .map((e) => ActionTemplate.fromMap(e))
          .toList();
      listListActions.add(
        ListAction(
          name: name,
          isWork: isWork,
          listActions: listAc,
        ),
      );
    }

    print("${getAll().length} ações carregadas");
  }

  ActionTemplate? getActionById(String id) {
    List<ActionTemplate> query =
        getAll().where((element) => element.id == id).toList();

    if (query.isNotEmpty) {
      return query[0];
    }

    return null;
  }

  List<ActionTemplate> getAll() {
    return listListActions.expand((e) => e.listActions).toList();
  }

  bool isOnlyFreeOrPreparation(String id) {
    bool result = false;
    ActionTemplate? action = getActionById(id);

    if (action != null) {
      if ((action.isFree || action.isPreparation) &&
          !action.isReaction &&
          !action.isResisted) {
        result = true;
      }
    }

    return result;
  }

  bool isLuckAction(String id) {
    return id == "e025515c-ecd7-11ef-9cd2-0242ac120002";
  }

  List<ActionTemplate> getListActionsFromActionValues({
    required List<ActionValue> listAV,
    required bool isWork,
  }) {
    List<ActionTemplate> result = [];

    List<String> listIds = listAV.map((e) => e.actionId).toList();

    for (String id in listIds) {
      ActionTemplate action = getActionById(id)!;
      if (action.isWork == isWork) {
        result.add(action);
      }
    }

    return result;
  }

  List<ListAction> getListWorks() {
    return listListActions.where((e) => e.isWork == true).toList();
  }

  List<ActionTemplate> getActionsByGroupName(String typeId) {
    return listListActions.where((e) => e.name == typeId).first.listActions;
  }

  List<ActionTemplate> getBasics() {
    return getListActionByGroupName("basic").listActions;
  }

  List<ActionTemplate> getStrength() {
    return getListActionByGroupName("strength").listActions;
  }

  List<ActionTemplate> getAgility() {
    return getListActionByGroupName("agility").listActions;
  }

  List<ActionTemplate> getIntellect() {
    return getListActionByGroupName("intellect").listActions;
  }

  List<ActionTemplate> getSocial() {
    return getListActionByGroupName("social").listActions;
  }

  ListAction getListActionByGroupName(String groupName) {
    return listListActions.where((e) => e.name == groupName).first;
  }
}
