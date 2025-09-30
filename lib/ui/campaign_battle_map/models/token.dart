import 'dart:math';

import 'package:flutter/widgets.dart';

class Token {
  final String id;
  final String battleMapId;
  final String imageUrl;

  final Point<double> position;
  final Size size;
  final double rotationDeg;

  final int zIndex;

  final bool isVisible;

  final List<String> owners;
  final bool stickGrid;

  final String? sheetId;

  Token({
    required this.id,
    required this.battleMapId,
    required this.imageUrl,
    required this.position,
    required this.size,
    required this.rotationDeg,
    required this.zIndex,
    required this.isVisible,
    required this.owners,
    required this.stickGrid,
    this.sheetId,
  });

  Token copyWith({
    String? id,
    String? battleMapId,
    String? imageUrl,
    Point<double>? position,
    Size? sizeNorm,
    double? rotationDeg,
    int? zIndex,
    bool? isVisible,
    List<String>? owners,
    bool? stickGrid,
    String? sheetId,
  }) {
    return Token(
      id: id ?? this.id,
      battleMapId: battleMapId ?? this.battleMapId,
      imageUrl: imageUrl ?? this.imageUrl,
      position: position ?? this.position,
      size: sizeNorm ?? size,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      zIndex: zIndex ?? this.zIndex,
      isVisible: isVisible ?? this.isVisible,
      owners: owners ?? this.owners,
      stickGrid: stickGrid ?? this.stickGrid,
      sheetId: sheetId ?? this.sheetId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mapId': battleMapId,
      'imageUrl': imageUrl,
      'obeyGrid': stickGrid,
      'size': {'w': size.width, 'h': size.height},
      'position': {'x': position.x, 'y': position.y},
      'rotationDeg': rotationDeg,
      'zIndex': zIndex,
      'isVisible': isVisible,
      'owners': owners,
      'sheetId': sheetId,
    };
  }

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      id: map['id'],
      battleMapId: map['mapId'],
      imageUrl: map['imageUrl'],
      stickGrid: map['obeyGrid'] as bool,
      size: Size(
        (map['size']['w'] as num).toDouble(),
        (map['size']['h'] as num).toDouble(),
      ),
      position: map['position'] == null
          ? Point<double>(0, 0)
          : Point<double>(
              (map['position']['x'] as num).toDouble(),
              (map['position']['y'] as num).toDouble(),
            ),
      rotationDeg: (map['rotationDeg'] as num?)?.toDouble() ?? 0,
      zIndex: map['zIndex'] ?? 0,
      isVisible: map['isVisible'] ?? true,
      owners: List<String>.from(map['owners'] ?? const []),
      sheetId: map['sheetId'],
    );
  }
}
