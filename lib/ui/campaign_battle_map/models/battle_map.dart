import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'token.dart';

class BattleMap {
  String id;
  String name;
  int rows;
  int columns;
  String imageUrl;
  Size imageSize;
  String? ambienceId;
  String? musicId;

  List<Token> listTokens;

  double gridOpacity;
  int gridColor;

  BattleMap({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
    required this.imageUrl,
    required this.imageSize,
    this.ambienceId,
    this.musicId,
    required this.listTokens,
    required this.gridOpacity,
    required this.gridColor,
  });

  BattleMap copyWith({
    String? id,
    String? name,
    int? rows,
    int? columns,
    String? imageUrl,
    Size? imageSize,
    String? ambienceId,
    String? musicId,
    List<Token>? listTokens,
    double? gridOpacity,
    int? gridColor,
  }) {
    return BattleMap(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      imageUrl: imageUrl ?? this.imageUrl,
      imageSize: imageSize ?? this.imageSize,
      ambienceId: ambienceId ?? this.ambienceId,
      musicId: musicId ?? this.musicId,
      listTokens: listTokens ?? this.listTokens,
      gridOpacity: gridOpacity ?? this.gridOpacity,
      gridColor: gridColor ?? this.gridColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rows': rows,
      'columns': columns,
      'imageUrl': imageUrl,
      'imageSize': {'width': imageSize.width, 'height': imageSize.height},
      'ambienceId': ambienceId,
      'musicId': musicId,
      'listTokens': listTokens.map((x) => x.toMap()).toList(),
      'gridOpacity': gridOpacity,
      'gridColor': gridColor,
    };
  }

  factory BattleMap.fromMap(Map<String, dynamic> map) {
    return BattleMap(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rows: map['rows']?.toInt() ?? 0,
      columns: map['columns']?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      imageSize: map['imageSize'] != null
          ? Size(map['imageSize']['width'], map['imageSize']['height'])
          : Size(1920, 1080),
      ambienceId: map['ambienceId'],
      musicId: map['musicId'],
      listTokens: List<Token>.from(
        map['listTokens']?.map((x) => Token.fromMap(x)),
      ),
      gridOpacity: map['gridOpacity']?.toDouble() ?? 0,
      gridColor: map['gridColor']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BattleMap.fromJson(String source) =>
      BattleMap.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BattleMap(id: $id, name: $name, rows: $rows, columns: $columns, imageUrl: $imageUrl, imageSize: $imageSize, ambienceId: $ambienceId, musicId: $musicId, listTokens: $listTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BattleMap &&
        other.id == id &&
        other.name == name &&
        other.rows == rows &&
        other.columns == columns &&
        other.imageUrl == imageUrl &&
        other.imageSize == imageSize &&
        other.ambienceId == ambienceId &&
        other.musicId == musicId &&
        listEquals(other.listTokens, listTokens);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        rows.hashCode ^
        columns.hashCode ^
        imageUrl.hashCode ^
        imageSize.hashCode ^
        ambienceId.hashCode ^
        musicId.hashCode ^
        listTokens.hashCode;
  }
}
