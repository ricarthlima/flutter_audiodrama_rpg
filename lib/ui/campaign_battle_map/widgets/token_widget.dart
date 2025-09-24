// ignore_for_file: unused_element

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign_battle_map/models/battle_map.dart';
import '../controllers/battle_map_controller.dart';

import '../models/token.dart';

/// Recebe um token e mostra-o. Deverá ser usado sobre o grid;
/// Deverá ser arrastável, e quando arrastado, mudar de posição no grid;
/// Deverá ser redimensionável, e ao redimensionar, aumentar/diminuir no grid;
class TokenWidget extends StatelessWidget {
  final Token token;
  final BattleMap battleMap;
  const TokenWidget({super.key, required this.token, required this.battleMap});

  @override
  Widget build(BuildContext context) {
    return Draggable<Token>(
      data: token,
      feedback: Material(
        child: SizedBox(
          width: (battleMap.imageSize.width / battleMap.columns),
          height: (battleMap.imageSize.height / battleMap.rows),
          child: Image.network(token.imageUrl, fit: BoxFit.contain),
        ),
      ),
      child: Transform.rotate(
        angle: token.rotationDeg * pi / 180.0,
        child: Image.network(token.imageUrl, fit: BoxFit.contain),
      ),
    );
  }

  void _showSettingsDialog() {
    //TODO: Abrir dialog de configurações do Token
  }

  void _onPan({
    required BattleMapController gridCTRL,
    required Point<double> point,
  }) {
    gridCTRL.panToken(token: token, point: point);
  }

  void _onResize({
    required BattleMapController gridCTRL,
    required Offset size,
  }) {
    gridCTRL.resizeToken(token: token, size: size);
  }

  void _onRemove({required BattleMapController gridCTRL}) {
    gridCTRL.removeToken(token: token);
  }
}
