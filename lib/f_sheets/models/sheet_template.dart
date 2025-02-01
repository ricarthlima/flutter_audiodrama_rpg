import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rpg_audiodrama/f_sheets/models/action_template.dart';

class SheetTemplate {
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

  SheetTemplate._();
  static final SheetTemplate _instance = SheetTemplate._();
  static SheetTemplate get instance {
    return _instance;
  }

  Future<void> initialize() async {
    String jsonString = await rootBundle.loadString('sheets/acoes-0.0.1b.json');
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
}
