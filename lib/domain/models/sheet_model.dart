import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_custom_count.dart';

import 'action_lore.dart';
import 'action_value.dart';
import 'item_sheet.dart';
import 'roll_log.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Sheet {
  String id;
  String characterName;
  int stressPoints;
  List<ActionValue> listActionValue;
  List<RollLog> listRollLog;
  int baseLevel;
  List<ItemSheet> listItemSheet;

  double money;
  double weight;

  List<ActionLore> listActionLore;

  String bio;
  String notes;

  int condition;

  String? imageUrl;

  List<String> listActiveWorks;
  List<ActionValue> listWorks;

  String? campaignId;
  List<String> listSharedIds;
  String ownerId;

  int exhaustPoints;

  List<String> listActiveModules;
  List<String> listSpell;

  List<SheetCustomCount> listCustomCount;

  Map<String, bool> booleans;

  Sheet({
    required this.id,
    required this.characterName,
    required this.stressPoints,
    required this.listActionValue,
    required this.listRollLog,
    required this.baseLevel,
    required this.listItemSheet,
    required this.money,
    required this.weight,
    required this.listActionLore,
    required this.bio,
    required this.notes,
    required this.condition,
    this.imageUrl,
    required this.listActiveWorks,
    required this.listWorks,
    this.campaignId,
    required this.listSharedIds,
    required this.ownerId,
    required this.exhaustPoints,
    required this.listSpell,
    required this.listActiveModules,
    required this.listCustomCount,
    required this.booleans,
  });

  Sheet copyWith({
    String? id,
    String? characterName,
    int? stressLevel,
    int? stressPoints,
    List<ActionValue>? listActionValue,
    List<RollLog>? listRollLog,
    int? baseLevel,
    List<ItemSheet>? listItemSheet,
    double? money,
    double? weight,
    List<ActionLore>? listActionLore,
    String? bio,
    String? notes,
    int? condition,
    String? imageUrl,
    List<String>? listActiveWorks,
    List<ActionValue>? listWorks,
    String? campaignId,
    List<String>? listSharedIds,
    String? ownerId,
    int? exhaustPoints,
    List<String>? listSpell,
    List<String>? listActiveModules,
    List<SheetCustomCount>? listCustomCount,
    Map<String, bool>? booleans,
  }) {
    return Sheet(
      id: id ?? this.id,
      characterName: characterName ?? this.characterName,
      stressPoints: stressPoints ?? this.stressPoints,
      listActionValue: listActionValue ?? this.listActionValue,
      listRollLog: listRollLog ?? this.listRollLog,
      baseLevel: baseLevel ?? this.baseLevel,
      listItemSheet: listItemSheet ?? this.listItemSheet,
      money: money ?? this.money,
      weight: weight ?? this.weight,
      listActionLore: listActionLore ?? this.listActionLore,
      bio: bio ?? this.bio,
      notes: notes ?? this.notes,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      listActiveWorks: listActiveWorks ?? this.listActiveWorks,
      listWorks: listWorks ?? this.listWorks,
      listSharedIds: listSharedIds ?? this.listSharedIds,
      campaignId: campaignId ?? this.campaignId,
      ownerId: ownerId ?? this.ownerId,
      exhaustPoints: exhaustPoints ?? this.exhaustPoints,
      listSpell: listSpell ?? this.listSpell,
      listActiveModules: listActiveModules ?? this.listActiveModules,
      listCustomCount: listCustomCount ?? this.listCustomCount,
      booleans: booleans ?? this.booleans,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'characterName': characterName,
      'stressPoints': stressPoints,
      'listActionValue': listActionValue.map((x) => x.toMap()).toList(),
      'listRollLog': listRollLog.map((x) => x.toMap()).toList(),
      'baseLevel': baseLevel,
      'listItemSheet': listItemSheet.map((x) => x.toMap()).toList(),
      "money": money,
      "weight": weight,
      'listActionLore': listActionLore.map((x) => x.toMap()).toList(),
      "bio": bio,
      "notes": notes,
      "condition": condition,
      "imageUrl": imageUrl,
      "listActiveWorks": listActiveWorks,
      "listWorks": listWorks.map((x) => x.toMap()).toList(),
      "campaignId": campaignId,
      "listSharedIds": listSharedIds,
      "ownerId": ownerId,
      "exhaustPoints": exhaustPoints,
      "listSpell": listSpell,
      "listActiveModules": listActiveModules,
      'listCustomCount': listCustomCount.map((x) => x.toMap()).toList(),
      'booleans': booleans,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    Map<String, dynamic> map = toMap();
    map.remove("id");
    return map;
  }

  factory Sheet.fromMap(Map<String, dynamic> map) {
    return Sheet(
      id: map['id'] != null ? map['id'] as String : "",
      characterName: map['characterName'] != null
          ? map['characterName'] as String
          : "",
      stressPoints: map['stressPoints'] != null
          ? map['stressPoints'] as int
          : 0,
      listActionValue: map['listActionValue'] != null
          ? List<ActionValue>.from(
              (map['listActionValue'] as List<dynamic>).map<ActionValue>(
                (x) => ActionValue.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      listRollLog: map['listRollLog'] != null
          ? List<RollLog>.from(
              (map['listRollLog'] as List<dynamic>).map<RollLog>(
                (x) => RollLog.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      baseLevel: map['baseLevel'] != null ? map['baseLevel'] as int : 0,
      listItemSheet: map['listItemSheet'] != null
          ? List<ItemSheet>.from(
              (map['listItemSheet'] as List<dynamic>).map<ItemSheet>(
                (x) => ItemSheet.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      money: (map["money"] ?? 0 as num).toDouble(),
      weight: (map["weight"] ?? 0 as num).toDouble(),
      listActionLore: map['listActionLore'] != null
          ? List<ActionLore>.from(
              (map['listActionLore'] as List<dynamic>).map<ActionLore>(
                (x) => ActionLore.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      bio: (map["bio"] != null) ? map["bio"] : "",
      notes: (map["notes"] != null) ? map["notes"] : "",
      condition: (map["condition"] ?? 0) as int,
      imageUrl: map["imageUrl"],
      listWorks: (map["listWorks"] != null)
          ? List<ActionValue>.from(
              (map['listWorks'] as List<dynamic>).map<ActionValue>(
                (x) => ActionValue.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      campaignId: map["campaignId"],
      listActiveWorks: (map["listActiveWorks"] != null)
          ? (map["listActiveWorks"] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
          : [],
      listSharedIds: (map["listSharedIds"] != null)
          ? (map["listSharedIds"] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
          : [],
      ownerId: (map["ownerId"] != null) ? map["ownerId"] : "",
      exhaustPoints: (map["exhaustPoints"] ?? 0) as int,
      listSpell: (map["listSpell"] != null)
          ? (map["listSpell"] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
          : [],
      listActiveModules: (map["listActiveModules"] != null)
          ? (map["listActiveModules"] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
          : [],
      listCustomCount: (map['listCustomCount'] != null)
          ? (map['listCustomCount'] as List<dynamic>)
                .map((e) => SheetCustomCount.fromMap(e))
                .toList()
          : [],
      booleans: (map['booleans'] != null)
          ? (map['booleans'] as Map<String, dynamic>).map((key, value) {
              return MapEntry(key, value as bool);
            })
          : {},
    );
  }

  String toJson() => json.encode(toMap());

  factory Sheet.fromJson(String source) =>
      Sheet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Sheet other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.characterName == characterName &&
        other.stressPoints == stressPoints &&
        listEquals(other.listActionValue, listActionValue) &&
        listEquals(other.listRollLog, listRollLog) &&
        other.baseLevel == baseLevel &&
        listEquals(other.listItemSheet, listItemSheet) &&
        listEquals(listActionLore, other.listActionLore) &&
        other.bio == bio &&
        other.notes == notes &&
        other.condition == condition &&
        other.imageUrl == imageUrl &&
        other.listWorks == listWorks &&
        other.campaignId == campaignId &&
        listEquals(other.listSharedIds, listSharedIds) &&
        other.ownerId == ownerId &&
        listEquals(other.listActiveWorks, listActiveWorks) &&
        exhaustPoints == other.exhaustPoints &&
        listSpell == other.listSpell &&
        listActiveModules == other.listActiveModules &&
        listCustomCount == other.listCustomCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        characterName.hashCode ^
        stressPoints.hashCode ^
        listActionValue.hashCode ^
        listRollLog.hashCode ^
        baseLevel.hashCode ^
        listItemSheet.hashCode ^
        listActionLore.hashCode ^
        notes.hashCode ^
        bio.hashCode ^
        condition.hashCode ^
        imageUrl.hashCode ^
        listWorks.hashCode ^
        campaignId.hashCode ^
        listSharedIds.hashCode ^
        ownerId.hashCode ^
        listActiveWorks.hashCode ^
        exhaustPoints.hashCode ^
        listSpell.hashCode ^
        listActiveModules.hashCode ^
        listCustomCount.hashCode;
  }

  @override
  String toString() {
    return 'Sheet(id: $id, characterName: $characterName, stressPoints: $stressPoints, listActionValue: $listActionValue, listRollLog: $listRollLog, baseLevel: $baseLevel, listItemSheet: $listItemSheet, money: $money, weight: $weight, listActionLore: $listActionLore, bio: $bio, notes: $notes, condition: $condition, imageUrl: $imageUrl, listActiveWorks: $listActiveWorks, listWorks: $listWorks, campaignId: $campaignId, listSharedIds: $listSharedIds, ownerId: $ownerId, exhaustPoints: $exhaustPoints)';
  }
}
