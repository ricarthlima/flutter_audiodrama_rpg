import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_lore.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_value.dart';

import 'package:flutter_rpg_audiodrama/domain/models/item_sheet.dart';
import 'package:flutter_rpg_audiodrama/domain/models/roll_log.dart';

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

  double money;
  double weight;

  List<ActionLore> listActionLore;

  String bio;
  String notes;

  List<String> listActiveConditions;

  String? imageUrl;

  List<ActionValue> listWorks;

  String? campaignId;
  List<String> listSharedIds;
  String ownerId;

  Sheet({
    required this.id,
    required this.characterName,
    required this.stressLevel,
    required this.effortPoints,
    required this.listActionValue,
    required this.listRollLog,
    required this.baseLevel,
    required this.listItemSheet,
    required this.money,
    required this.weight,
    required this.listActionLore,
    required this.bio,
    required this.notes,
    required this.listActiveConditions,
    this.imageUrl,
    required this.listWorks,
    this.campaignId,
    required this.listSharedIds,
    required this.ownerId,
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
    double? money,
    double? weight,
    List<ActionLore>? listActionLore,
    String? bio,
    String? notes,
    List<String>? listActiveConditions,
    String? imageUrl,
    List<ActionValue>? listWorks,
    String? campaignId,
    List<String>? listSharedIds,
    String? ownerId,
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
      money: money ?? this.money,
      weight: weight ?? this.weight,
      listActionLore: listActionLore ?? this.listActionLore,
      bio: bio ?? this.bio,
      notes: notes ?? this.notes,
      listActiveConditions: listActiveConditions ?? this.listActiveConditions,
      imageUrl: imageUrl ?? this.imageUrl,
      listWorks: listWorks ?? this.listWorks,
      listSharedIds: listSharedIds ?? this.listSharedIds,
      campaignId: campaignId ?? this.campaignId,
      ownerId: ownerId ?? this.ownerId,
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
      "money": money,
      "weight": weight,
      'listActionLore': listActionLore.map((x) => x.toMap()).toList(),
      "bio": bio,
      "notes": notes,
      "listActiveConditions": listActiveConditions,
      "imageUrl": imageUrl,
      "listWorks": listWorks.map((x) => x.toMap()).toList(),
      "campaignId": campaignId,
      "listSharedIds": listSharedIds,
      "ownerId": ownerId,
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
      money: (map["money"] ?? 0) as double,
      weight: (map["weight"] ?? 0) as double,
      listActionLore: map['listActionLore'] != null
          ? List<ActionLore>.from(
              (map['listActionLore'] as List<dynamic>).map<ActionLore>(
                (x) => ActionLore.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      bio: (map["bio"] != null) ? map["bio"] : "",
      notes: (map["notes"] != null) ? map["notes"] : "",
      listActiveConditions: (map["listActiveConditions"] != null)
          ? (map["listActiveConditions"] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      imageUrl: map["imageUrl"],
      listWorks: (map["listWorks"] != null)
          ? List<ActionValue>.from(
              (map['listWorks'] as List<dynamic>).map<ActionValue>(
                (x) => ActionValue.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      campaignId: map["campaignId"],
      listSharedIds: (map["listSharedIds"] != null)
          ? (map["listSharedIds"] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      ownerId: (map["ownerId"] != null) ? map["ownerId"] : "",
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
        listEquals(other.listItemSheet, listItemSheet) &&
        listEquals(listActionLore, other.listActionLore) &&
        other.bio == bio &&
        other.notes == notes &&
        other.listActiveConditions == listActiveConditions &&
        other.imageUrl == imageUrl &&
        other.listWorks == listWorks &&
        other.campaignId == campaignId &&
        listEquals(other.listSharedIds, listSharedIds) &&
        other.ownerId == ownerId;
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
        listItemSheet.hashCode ^
        listActionLore.hashCode ^
        notes.hashCode ^
        bio.hashCode ^
        listActiveConditions.hashCode ^
        imageUrl.hashCode ^
        listWorks.hashCode ^
        campaignId.hashCode ^
        listSharedIds.hashCode ^
        ownerId.hashCode;
  }
}
