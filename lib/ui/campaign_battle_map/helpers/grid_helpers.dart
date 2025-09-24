import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../models/token.dart';

Offset viewportToScene(Offset viewportPoint, Matrix4 m) {
  final Matrix4 inv = Matrix4.inverted(m);
  final Vector3 v = Vector3(viewportPoint.dx, viewportPoint.dy, 0)
    ..applyMatrix4(inv);
  return Offset(v.x, v.y);
}

Offset sceneToViewport(Offset scenePoint, Matrix4 m) {
  final Vector3 v = Vector3(scenePoint.dx, scenePoint.dy, 0)..applyMatrix4(m);
  return Offset(v.x, v.y);
}

// // Snap ao grid (coords já normalizadas)
// Offset snapToGrid(Offset s, BattleMap g) {
//   final double nx = (s.dx / g.rows).round() * g.rows;
//   final double ny = (s.dy / g.columns).round() * g.columns;
//   return Offset(nx, ny);
// }

class GridSpec {
  final int cols;
  final int rows;
  const GridSpec({required this.cols, required this.rows});
}

class CellMetrics {
  final double cellW;
  final double cellH;
  const CellMetrics(this.cellW, this.cellH);
}

CellMetrics cellMetrics(Size imageSize, GridSpec grid) {
  return CellMetrics(imageSize.width / grid.cols, imageSize.height / grid.rows);
}

Point<int> sceneToGrid(Offset scene, Size imageSize, GridSpec grid) {
  final m = cellMetrics(imageSize, grid);
  final gx = (scene.dx / m.cellW).floor().clamp(0, grid.cols - 1);
  final gy = (scene.dy / m.cellH).floor().clamp(0, grid.rows - 1);
  return Point(gx, gy);
}

Offset gridToSceneTopLeft(Point<int> gridCell, Size imageSize, GridSpec grid) {
  final m = cellMetrics(imageSize, grid);
  return Offset(gridCell.x * m.cellW, gridCell.y * m.cellH);
}

Rect tokenRectPx(Token t, Size imageSize, {GridSpec? grid}) {
  final double imageW = imageSize.width;
  final double imageH = imageSize.height;

  Offset centerPx;
  Size sizePx;

  if (t.obeyGrid &&
      t.centerGrid != null &&
      t.sizeGrid != null &&
      grid != null) {
    final double cellW = imageW / grid.cols;
    final double cellH = imageH / grid.rows;
    centerPx = Offset(t.centerGrid!.x * cellW, t.centerGrid!.y * cellH);
    sizePx = Size(t.sizeGrid!.width * cellW, t.sizeGrid!.height * cellH);
  } else {
    centerPx = Offset(t.centerNorm.dx * imageW, t.centerNorm.dy * imageH);
    sizePx = Size(t.sizeNorm.width * imageW, t.sizeNorm.height * imageH);
  }

  return Rect.fromCenter(
    center: centerPx,
    width: sizePx.width,
    height: sizePx.height,
  );
}
