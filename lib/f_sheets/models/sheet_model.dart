import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_rpg_audiodrama/f_sheets/models/item_sheet.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Sheet {
  String id;
  String characterName;
  int stressLevel;
  int effortPoints;
  List<ActionValue> listActionValue;
  List<RollLog> listRollLog;
  int baseLevel;
  List<ItemSheet> listItemSheet;
  Sheet({
    required this.id,
    required this.characterName,
    required this.stressLevel,
    required this.effortPoints,
    required this.listActionValue,
    required this.listRollLog,
    required this.baseLevel,
    required this.listItemSheet,
  });

  Sheet copyWith({
    String? id,
    String? characterName,
    int? stressLevel,
    int? effortPoints,
    List<ActionValue>? listActionValue,
    List<RollLog>? listRollLog,
    int? baseLevel,
    List<ItemSheet>? listItemSheet,
  }) {
    return Sheet(
      id: id ?? this.id,
      characterName: characterName ?? this.characterName,
      stressLevel: stressLevel ?? this.stressLevel,
      effortPoints: effortPoints ?? this.effortPoints,
      listActionValue: listActionValue ?? this.listActionValue,
      listRollLog: listRollLog ?? this.listRollLog,
      baseLevel: baseLevel ?? this.baseLevel,
      listItemSheet: listItemSheet ?? this.listItemSheet,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'characterName': characterName,
      'stressLevel': stressLevel,
      'effortPoints': effortPoints,
      'listActionValue': listActionValue.map((x) => x.toMap()).toList(),
      'listRollLog': listRollLog.map((x) => x.toMap()).toList(),
      'baseLevel': baseLevel,
      'listItemSheet': listItemSheet.map((x) => x.toMap()).toList(),
    };
  }

  factory Sheet.fromMap(Map<String, dynamic> map) {
    return Sheet(
      id: map['id'] as String,
      characterName: map['characterName'] as String,
      stressLevel: map['stressLevel'] as int,
      effortPoints: map['effortPoints'] as int,
      listActionValue: List<ActionValue>.from(
        (map['listActionValue'] as List<dynamic>).map<ActionValue>(
          (x) => ActionValue.fromMap(x as Map<String, dynamic>),
        ),
      ),
      listRollLog: List<RollLog>.from(
        (map['listRollLog'] as List<dynamic>).map<RollLog>(
          (x) => RollLog.fromMap(x as Map<String, dynamic>),
        ),
      ),
      baseLevel: map['baseLevel'] as int,
      listItemSheet: map['listItemSheet'] != null
          ? List<ItemSheet>.from(
              (map['listItemSheet'] as List<dynamic>).map<ItemSheet>(
                (x) => ItemSheet.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Sheet.fromJson(String source) =>
      Sheet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Sheet(id: $id, characterName: $characterName, stressLevel: $stressLevel, effortPoints: $effortPoints, listActionValue: $listActionValue, listRollLog: $listRollLog, baseLevel: $baseLevel, listItemSheet: $listItemSheet)';
  }

  @override
  bool operator ==(covariant Sheet other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.characterName == characterName &&
        other.stressLevel == stressLevel &&
        other.effortPoints == effortPoints &&
        listEquals(other.listActionValue, listActionValue) &&
        listEquals(other.listRollLog, listRollLog) &&
        other.baseLevel == baseLevel &&
        listEquals(other.listItemSheet, listItemSheet);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        characterName.hashCode ^
        stressLevel.hashCode ^
        effortPoints.hashCode ^
        listActionValue.hashCode ^
        listRollLog.hashCode ^
        baseLevel.hashCode ^
        listItemSheet.hashCode;
  }
}

class ActionValue {
  String actionId;
  int value;

  ActionValue({
    required this.actionId,
    required this.value,
  });

  ActionValue copyWith({
    String? actionId,
    int? value,
  }) {
    return ActionValue(
      actionId: actionId ?? this.actionId,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actionId': actionId,
      'value': value,
    };
  }

  factory ActionValue.fromMap(Map<String, dynamic> map) {
    return ActionValue(
      actionId: map['actionId'] as String,
      value: map['value'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionValue.fromJson(String source) =>
      ActionValue.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ActionValue(actionId: $actionId, value: $value)';

  @override
  bool operator ==(covariant ActionValue other) {
    if (identical(this, other)) return true;

    return other.actionId == actionId && other.value == value;
  }

  @override
  int get hashCode => actionId.hashCode ^ value.hashCode;
}

class RollLog {
  List<int> rolls;
  String idAction;
  DateTime dateTime;
  bool isGettingLower;

  RollLog({
    required this.rolls,
    required this.idAction,
    required this.dateTime,
    required this.isGettingLower,
  });

  RollLog copyWith({
    List<int>? rolls,
    String? idAction,
    DateTime? dateTime,
    bool? isGettingLower,
  }) {
    return RollLog(
      rolls: rolls ?? this.rolls,
      idAction: idAction ?? this.idAction,
      dateTime: dateTime ?? this.dateTime,
      isGettingLower: isGettingLower ?? this.isGettingLower,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rolls': rolls,
      'idAction': idAction,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'isGettingLower': isGettingLower,
    };
  }

  factory RollLog.fromMap(Map<String, dynamic> map) {
    return RollLog(
      rolls: List<int>.from((map['rolls'] as List<dynamic>)),
      idAction: map['idAction'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      isGettingLower: map['isGettingLower'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory RollLog.fromJson(String source) =>
      RollLog.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RollLog(rolls: $rolls, idAction: $idAction, dateTime: $dateTime, isGettingLower: $isGettingLower)';
  }

  @override
  bool operator ==(covariant RollLog other) {
    if (identical(this, other)) return true;

    return listEquals(other.rolls, rolls) &&
        other.idAction == idAction &&
        other.dateTime == dateTime &&
        other.isGettingLower == isGettingLower;
  }

  @override
  int get hashCode {
    return rolls.hashCode ^
        idAction.hashCode ^
        dateTime.hashCode ^
        isGettingLower.hashCode;
  }
}
