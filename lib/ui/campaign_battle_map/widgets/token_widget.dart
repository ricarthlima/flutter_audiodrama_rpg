// ignore_for_file: unused_element

import 'dart:math';

import 'package:flutter/material.dart';

import '../models/token.dart';

/// Recebe um token e mostra-o. Deverá ser usado sobre o grid;
/// Deverá ser arrastável, e quando arrastado, mudar de posição no grid;
/// Deverá ser redimensionável, e ao redimensionar, aumentar/diminuir no grid;
class TokenWidget extends StatelessWidget {
  final Token token;
  final Size sizeInGrid;
  const TokenWidget({super.key, required this.token, required this.sizeInGrid});

  @override
  Widget build(BuildContext context) {
    return Draggable<Token>(
      data: token,
      feedback: Material(child: _buildImage()),
      child: _buildImage(),
    );
  }

  Container _buildImage() {
    return Container(
      color: Colors.black.withAlpha(100),
      alignment: Alignment.center,
      width: sizeInGrid.width,
      height: sizeInGrid.height,
      child: Stack(
        children: [
          Transform.rotate(
            angle: token.rotationDeg * pi / 180.0,
            child: Image.network(token.imageUrl, fit: BoxFit.contain),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ColoredBox(
              color: Colors.black,
              child: Text(
                "${token.position.x.floor()}:${token.position.y.floor()}\n${token.size.width.floor()}x${token.size.height.floor()}",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    //TODO: Abrir dialog de configurações do Token
  }
}
