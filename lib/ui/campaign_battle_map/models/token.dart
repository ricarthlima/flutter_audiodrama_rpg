import 'dart:math';
import 'dart:ui';

class Token {
  final String id;
  final String mapId;
  final String imageUrl;
  final bool obeyGrid;
  final Offset centerNorm;
  final Size sizeNorm;
  final Point<double>? centerGrid;
  final Size? sizeGrid;
  final double rotationDeg;
  final int zIndex;
  final bool isVisible;
  final List<String> owners;

  const Token({
    required this.id,
    required this.mapId,
    required this.imageUrl,
    required this.obeyGrid,
    required this.centerNorm,
    required this.sizeNorm,
    this.centerGrid,
    this.sizeGrid,
    this.rotationDeg = 0,
    this.zIndex = 0,
    this.isVisible = true,
    required this.owners,
  });

  Token copyWith({
    String? id,
    String? mapId,
    String? imageUrl,
    bool? obeyGrid,
    Offset? centerNorm,
    Size? sizeNorm,
    Point<double>? centerGrid,
    Size? sizeGrid,
    double? rotationDeg,
    int? zIndex,
    bool? isVisible,
    List<String>? owners,
  }) {
    return Token(
      id: id ?? this.id,
      mapId: mapId ?? this.mapId,
      imageUrl: imageUrl ?? this.imageUrl,
      obeyGrid: obeyGrid ?? this.obeyGrid,
      centerNorm: centerNorm ?? this.centerNorm,
      sizeNorm: sizeNorm ?? this.sizeNorm,
      centerGrid: centerGrid ?? this.centerGrid,
      sizeGrid: sizeGrid ?? this.sizeGrid,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      zIndex: zIndex ?? this.zIndex,
      isVisible: isVisible ?? this.isVisible,
      owners: owners ?? this.owners,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mapId': mapId,
      'imageUrl': imageUrl,
      'obeyGrid': obeyGrid,
      'centerNorm': {'x': centerNorm.dx, 'y': centerNorm.dy},
      'sizeNorm': {'w': sizeNorm.width, 'h': sizeNorm.height},
      'centerGrid': centerGrid == null
          ? null
          : {'x': centerGrid!.x, 'y': centerGrid!.y},
      'sizeGrid': sizeGrid == null
          ? null
          : {'w': sizeGrid!.width, 'h': sizeGrid!.height},
      'rotationDeg': rotationDeg,
      'zIndex': zIndex,
      'isVisible': isVisible,
      'owners': owners,
    };
  }

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      id: map['id'],
      mapId: map['mapId'],
      imageUrl: map['imageUrl'],
      obeyGrid: map['obeyGrid'] as bool,
      centerNorm: Offset(
        (map['centerNorm']['x'] as num).toDouble(),
        (map['centerNorm']['y'] as num).toDouble(),
      ),
      sizeNorm: Size(
        (map['sizeNorm']['w'] as num).toDouble(),
        (map['sizeNorm']['h'] as num).toDouble(),
      ),
      centerGrid: map['centerGrid'] == null
          ? null
          : Point<double>(
              (map['centerGrid']['x'] as num).toDouble(),
              (map['centerGrid']['y'] as num).toDouble(),
            ),
      sizeGrid: map['sizeGrid'] == null
          ? null
          : Size(
              (map['sizeGrid']['w'] as num).toDouble(),
              (map['sizeGrid']['h'] as num).toDouble(),
            ),
      rotationDeg: (map['rotationDeg'] as num?)?.toDouble() ?? 0,
      zIndex: map['zIndex'] ?? 0,
      isVisible: map['isVisible'] ?? true,
      owners: List<String>.from(map['owners'] ?? const []),
    );
  }
}
