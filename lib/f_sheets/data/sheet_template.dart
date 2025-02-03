import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rpg_audiodrama/f_sheets/models/action_template.dart';

class SheetDAO {
  static const String labelBasicActions = "basic";
  static const String labelStrengthActions = "strength";
  static const String labelAgilityActions = "agility";
  static const String labelIntellectActions = "intellect";
  static const String labelSocialActions = "social";

  List<ActionTemplate> listBasicActions = [];
  List<ActionTemplate> listStrengthActions = [];
  List<ActionTemplate> listAgilityActions = [];
  List<ActionTemplate> listIntellectActions = [];
  List<ActionTemplate> listSocialActions = [];

  SheetDAO._();
  static final SheetDAO _instance = SheetDAO._();
  static SheetDAO get instance {
    return _instance;
  }

  Future<void> initialize() async {
    String jsonString =
        await rootBundle.loadString('assets/sheets/acoes-0.0.1b.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    listBasicActions = (jsonData[labelBasicActions] as List<dynamic>)
        .map((e) => ActionTemplate.fromMap(e))
        .toList();
    listIntellectActions = (jsonData[labelIntellectActions] as List<dynamic>)
        .map((e) => ActionTemplate.fromMap(e))
        .toList();
    listStrengthActions = (jsonData[labelStrengthActions] as List<dynamic>)
        .map((e) => ActionTemplate.fromMap(e))
        .toList();
    listSocialActions = (jsonData[labelSocialActions] as List<dynamic>)
        .map((e) => ActionTemplate.fromMap(e))
        .toList();
    listAgilityActions = (jsonData[labelAgilityActions] as List<dynamic>)
        .map((e) => ActionTemplate.fromMap(e))
        .toList();
    print("$totalActions ações carregadas");
  }

  int get totalActions {
    return listBasicActions.length +
        listIntellectActions.length +
        listStrengthActions.length +
        listSocialActions.length +
        listAgilityActions.length;
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
    return listAgilityActions +
        listBasicActions +
        listIntellectActions +
        listSocialActions +
        listStrengthActions;
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
}
