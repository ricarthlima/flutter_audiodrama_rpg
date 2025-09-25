import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_rpg_audiodrama/data/repositories_remote/remote_mixin.dart';

class Spell implements FromMap {
  String id;
  String energy;
  String name;
  String verbal;
  String description;
  List<String> actions;
  String range;
  List<String> tags;
  bool isBond;
  bool isResisted;
  bool hasBaseTest;
  List<String> actionIds;
  String? source;
  bool isBeta;

  Spell({
    required this.id,
    required this.energy,
    required this.name,
    required this.verbal,
    required this.description,
    required this.actions,
    required this.range,
    required this.tags,
    required this.isBond,
    required this.isResisted,
    required this.hasBaseTest,
    required this.actionIds,
    this.source,
    required this.isBeta,
  });

  Spell copyWith({
    String? id,
    String? energy,
    String? name,
    String? verbal,
    String? description,
    List<String>? actions,
    String? range,
    List<String>? tags,
    bool? isBond,
    bool? isResisted,
    bool? hasBaseTest,
    List<String>? actionIds,
    String? source,
    bool? isBeta,
  }) {
    return Spell(
      id: id ?? this.id,
      energy: energy ?? this.energy,
      name: name ?? this.name,
      verbal: verbal ?? this.verbal,
      description: description ?? this.description,
      actions: actions ?? this.actions,
      range: range ?? this.range,
      tags: tags ?? this.tags,
      isBond: isBond ?? this.isBond,
      isResisted: isResisted ?? this.isResisted,
      hasBaseTest: hasBaseTest ?? this.hasBaseTest,
      actionIds: actionIds ?? this.actionIds,
      source: source ?? this.source,
      isBeta: isBeta ?? this.isBeta,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'energy': energy,
      'name': name,
      'verbal': verbal,
      'description': description,
      'actions': actions,
      'range': range,
      'tags': tags,
      'isBond': isBond,
      'isResisted': isResisted,
      'hasBaseTest': hasBaseTest,
      'actionIds': actionIds,
      'source': source,
      'isBeta': isBeta,
    };
  }

  factory Spell.fromMap(Map<String, dynamic> map) {
    return Spell(
      id: (map['id'] as dynamic).toString(),
      energy: map['energy'] ?? '',
      name: map['name'] ?? '',
      verbal: map['verbal'] ?? '',
      description: map['description'] ?? '',
      actions: map['actions'] != null ? List<String>.from(map['actions']) : [],
      range: map['range'] ?? '',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      isBond: map['isBond'] ?? false,
      isResisted: map['isResisted'] ?? false,
      hasBaseTest: map['hasBaseTest'] ?? false,
      actionIds: map['actionIds'] != null
          ? List<String>.from(map['actionIds'])
          : [],
      source: map['source'],
      isBeta: map['isBeta'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Spell.fromJson(String source) => Spell.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Spell(id: $id, energy: $energy, name: $name, verbal: $verbal, description: $description, actions: $actions, range: $range, tags: $tags, isBond: $isBond, isResisted: $isResisted, hasBaseTest: $hasBaseTest, actionIds: $actionIds, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Spell &&
        other.id == id &&
        other.energy == energy &&
        other.name == name &&
        other.verbal == verbal &&
        other.description == description &&
        listEquals(other.actions, actions) &&
        other.range == range &&
        listEquals(other.tags, tags) &&
        other.isBond == isBond &&
        other.isResisted == isResisted &&
        other.hasBaseTest == hasBaseTest &&
        listEquals(other.actionIds, actionIds) &&
        other.source == source;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        energy.hashCode ^
        name.hashCode ^
        verbal.hashCode ^
        description.hashCode ^
        actions.hashCode ^
        range.hashCode ^
        tags.hashCode ^
        isBond.hashCode ^
        isResisted.hashCode ^
        hasBaseTest.hashCode ^
        actionIds.hashCode ^
        source.hashCode;
  }
}
