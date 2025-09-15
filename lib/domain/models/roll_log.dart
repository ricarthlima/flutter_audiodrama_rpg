import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../ui/_core/constants/roll_type.dart';

class RollLog {
  List<int> rolls;
  String idAction;
  DateTime dateTime;
  bool isGettingLower;
  RollType rollType;
  String? idSpell;

  RollLog({
    required this.rolls,
    required this.idAction,
    required this.dateTime,
    required this.isGettingLower,
    required this.rollType,
    this.idSpell,
  });

  RollLog copyWith({
    List<int>? rolls,
    String? idAction,
    DateTime? dateTime,
    bool? isGettingLower,
    RollType? rollType,
    String? idSpell,
  }) {
    return RollLog(
      rolls: rolls ?? this.rolls,
      idAction: idAction ?? this.idAction,
      dateTime: dateTime ?? this.dateTime,
      isGettingLower: isGettingLower ?? this.isGettingLower,
      rollType: rollType ?? this.rollType,
      idSpell: idSpell ?? this.idSpell,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rolls': rolls,
      'idAction': idAction,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'isGettingLower': isGettingLower,
      'rollType': rollType.name,
      'idSpell': idSpell,
    };
  }

  factory RollLog.fromMap(Map<String, dynamic> map) {
    return RollLog(
      rolls: List<int>.from((map['rolls'] as List<dynamic>)),
      idAction: map['idAction'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      isGettingLower: map['isGettingLower'] as bool,
      rollType: map['rollType'] != null
          ? RollType.values.where((e) => e.name == map['rollType']).first
          : RollType.difficult,
      idSpell: map['idSpell'] != null ? map['idSpell'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RollLog.fromJson(String source) =>
      RollLog.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RollLog(rolls: $rolls, idAction: $idAction, dateTime: $dateTime, isGettingLower: $isGettingLower, rollType: $rollType, idSpell: $idSpell)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RollLog &&
        listEquals(other.rolls, rolls) &&
        other.idAction == idAction &&
        other.dateTime == dateTime &&
        other.isGettingLower == isGettingLower &&
        other.rollType == rollType &&
        other.idSpell == idSpell;
  }

  @override
  int get hashCode {
    return rolls.hashCode ^
        idAction.hashCode ^
        dateTime.hashCode ^
        isGettingLower.hashCode ^
        rollType.hashCode ^
        idSpell.hashCode;
  }
}
