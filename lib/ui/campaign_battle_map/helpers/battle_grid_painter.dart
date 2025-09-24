import 'package:flutter/material.dart';

class BattleGridPainter extends CustomPainter {
  final int cols;
  final int rows;
  final Color color;
  final double stroke; // 1.0 recomendado

  const BattleGridPainter({
    required this.cols,
    required this.rows,
    this.color = const Color(0x80FFFFFF),
    this.stroke = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellW = size.width / cols;
    final double cellH = size.height / rows;

    final Paint p = Paint()
      ..color = color
      ..strokeWidth = stroke;

    // Ajuste de meia unidade para nitidez em 1px
    final double ox = (stroke % 2 == 1) ? 0.5 : 0.0;
    final double oy = (stroke % 2 == 1) ? 0.5 : 0.0;

    // Verticais
    for (int c = 0; c <= cols; c++) {
      final double x = (c * cellW).roundToDouble() + ox;
      canvas.drawLine(Offset(x, 0.0 + oy), Offset(x, size.height + oy), p);
    }

    // Horizontais
    for (int r = 0; r <= rows; r++) {
      final double y = (r * cellH).roundToDouble() + oy;
      canvas.drawLine(Offset(0.0 + ox, y), Offset(size.width + ox, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant BattleGridPainter old) {
    return old.cols != cols ||
        old.rows != rows ||
        old.color != color ||
        old.stroke != stroke;
  }
}
