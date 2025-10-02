// ignore_for_file: unused_element

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/battle_map_controller.dart';
import '../models/token.dart';

/// Widget do token, arrastável com ancoragem no PONTEIRO
/// e sem "fantasma" bloqueando o DropTarget.
class TokenWidget extends StatelessWidget {
  final Token token;
  final Size sizeInGrid;
  const TokenWidget({super.key, required this.token, required this.sizeInGrid});

  // TokenWidget (apenas o build)
  @override
  Widget build(BuildContext context) {
    final double scale = context
        .read<CampaignOwnerBattleMapProvider>()
        .gridTrans
        .value
        .getMaxScaleOnAxis();
    return Draggable<Token>(
      data: token,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      childWhenDragging: const SizedBox.shrink(),
      feedback: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Material(type: MaterialType.transparency, child: _buildImage()),
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    return Container(
      width: sizeInGrid.width,
      height: sizeInGrid.height,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: token.rotationDeg * pi / 180.0,
        child: Image.network(token.imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
