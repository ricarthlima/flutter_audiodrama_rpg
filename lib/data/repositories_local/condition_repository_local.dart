import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/dto/condition.dart';
import '../repositories/condition_repository.dart';

class ConditionRepositoryLocal extends ConditionRepository {
  static const String _filePath = 'assets/sheets/conditions.json';

  List<Condition> _cachedConditions = [];

  @override
  Future<void> onInitialize() async {
    String jsonString = await rootBundle.loadString(_filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedConditions = (jsonData["conditions"] as List<dynamic>)
        .map((e) => Condition.fromMap(e))
        .toList();

    // Logger().i("${_cachedConditions.length} estados carregados");
  }

  @override
  List<Condition> getAll() => List.unmodifiable(_cachedConditions);
}
