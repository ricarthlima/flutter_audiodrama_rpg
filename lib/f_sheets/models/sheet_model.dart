import 'dart:convert';

import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SheetModel {
  String id;
  String characterName;
  List<ActionValue> listActionValue;
  List<RollLog> listRollLog;

  SheetModel({
    required this.id,
    required this.characterName,
    required this.listActionValue,
    required this.listRollLog,
  });

  SheetModel copyWith({
    String? id,
    String? characterName,
    List<ActionValue>? listActionValue,
    List<RollLog>? listRollLog,
  }) {
    return SheetModel(
      id: id ?? this.id,
      characterName: characterName ?? this.characterName,
      listActionValue: listActionValue ?? this.listActionValue,
      listRollLog: listRollLog ?? this.listRollLog,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'characterName': characterName,
      'listActionValue': listActionValue.map((x) => x.toMap()).toList(),
      'listRollLog': listRollLog.map((x) => x.toMap()).toList(),
    };
  }

  factory SheetModel.fromMap(Map<String, dynamic> map) {
    return SheetModel(
      id: map['id'] as String,
      characterName: map['characterName'] as String,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory SheetModel.fromJson(String source) =>
      SheetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SheetModel(id: $id, characterName: $characterName, listActionValue: $listActionValue, listRollLog: $listRollLog)';
  }

  @override
  bool operator ==(covariant SheetModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.characterName == characterName &&
        listEquals(other.listActionValue, listActionValue) &&
        listEquals(other.listRollLog, listRollLog);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        characterName.hashCode ^
        listActionValue.hashCode ^
        listRollLog.hashCode;
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
