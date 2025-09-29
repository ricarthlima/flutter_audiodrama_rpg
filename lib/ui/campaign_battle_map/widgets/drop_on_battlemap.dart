import 'dart:math';

import 'package:flutter/material.dart';

import '../helpers/grid_helpers.dart';

class DropOnBattleMap<T extends Object> extends StatefulWidget {
  final TransformationController controller;
  final Size imageSize; // largura/altura da imagem (em px)
  final GridSpec grid; // cols/rows (inteiros)
  final bool snapToCellCenter; // true = ancora no centro da célula
  final ValueChanged<DropResult<T>> onDrop;
  final Widget child;
  const DropOnBattleMap({
    super.key,
    required this.controller,
    required this.imageSize,
    required this.grid,
    this.snapToCellCenter = true,
    required this.onDrop,
    required this.child,
  });

  @override
  State<DropOnBattleMap<T>> createState() => _DropOnBattleMapState<T>();
}

class _DropOnBattleMapState<T extends Object>
    extends State<DropOnBattleMap<T>> {
  final GlobalKey _hitKey = GlobalKey();

  double get _cellW => widget.imageSize.width / widget.grid.cols;
  double get _cellH => widget.imageSize.height / widget.grid.rows;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: DragTarget<T>(
            builder: (_, __, ___) => Container(key: _hitKey),
            onAcceptWithDetails: (DragTargetDetails<T> details) {
              final RenderBox box =
                  _hitKey.currentContext!.findRenderObject() as RenderBox;
              final Offset viewportLocal = box.globalToLocal(details.offset);
              final Offset scene = widget.controller.toScene(viewportLocal);

              final double gx =
                  scene.dx / _cellW; // grid contínuo (0.0 = borda esquerda)
              final double gy =
                  scene.dy / _cellH; // grid contínuo (0.0 = borda superior)

              double cx = gx;
              double cy = gy;
              if (widget.snapToCellCenter) {
                // ancora no centro da célula atual: i + 0.5
                cx = gx.floorToDouble() + 0.5;
                cy = gy.floorToDouble() + 0.5;
              }

              final Offset sceneCenter = Offset(cx * _cellW, cy * _cellH);

              widget.onDrop(
                DropResult<T>(
                  data: details.data,
                  sceneCenter: sceneCenter, // px na cena (âncora no centro)
                  gridPos: Point<double>(
                    cx,
                    cy,
                  ), // posição no grid em doubles (centro da célula se snap ativo)
                  rawGridPos: Point<double>(
                    gx,
                    gy,
                  ), // contínuo, sem snap (útil se quiser liberdade total)
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DropResult<T extends Object> {
  final T data;
  final Offset sceneCenter; // ponto âncora em px (na cena)
  final Point<double>
  gridPos; // posição no grid (double). Inteiro + 0.5 = centro da célula
  final Point<double> rawGridPos; // posição contínua no grid, sem snap
  const DropResult({
    required this.data,
    required this.sceneCenter,
    required this.gridPos,
    required this.rawGridPos,
  });
}
