import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/dto/action_template.dart';
import '../../domain/dto/list_action.dart';
import '../repositories/action_repository.dart';

class ActionRepositoryLocal extends ActionRepository {
  static const String _filePath = 'assets/sheets/actions.json';
  final List<ListAction> _cachedListActions = [];

  @override
  Future<void> onInitialize() async {
    String jsonString = await rootBundle.loadString(_filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);

    for (String key in jsonData.keys) {
      String name = key;
      bool isWork = (jsonData[key] as List<dynamic>).first["isWork"];
      List<ActionTemplate> listAc = (jsonData[key] as List<dynamic>)
          .map((e) => ActionTemplate.fromMap(e))
          .toList();
      _cachedListActions.add(
        ListAction(name: name, isWork: isWork, listActions: listAc),
      );
    }

    // Logger().i("${getAllActions().length} ações carregadas");
  }

  @override
  List<ListAction> getAll() => List.unmodifiable(_cachedListActions);
}
