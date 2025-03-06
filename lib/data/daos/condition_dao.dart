import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/domain/models/condition.dart';

class ConditionDAO {
  static const String _filePath = 'assets/sheets/conditions-0.0.2.json';
  List<Condition> _listCondition = [];

  ConditionDAO._();
  static final ConditionDAO _instance = ConditionDAO._();
  static ConditionDAO get instance {
    return _instance;
  }

  Future<void> initialize() async {
    String jsonString = await rootBundle.loadString(_filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);

    _listCondition = (jsonData["conditions"] as List<dynamic>)
        .map((e) => Condition.fromMap(e))
        .toList();

    print("${_listCondition.length} estados carregados");
  }

  List<Condition> get getConditions {
    _listCondition.sort(
      (a, b) => a.showingOrder.compareTo(b.showingOrder),
    );
    return _listCondition;
  }

  Condition? getConditionById(String id) {
    List<Condition> query = _listCondition.where((e) => e.id == id).toList();
    if (query.isNotEmpty) {
      return query[0];
    }
    return null;
  }
}
