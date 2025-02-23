import 'dart:ui';

ColorFilter colorFilterInverter = ColorFilter.matrix([
  -1, 0, 0, 0, 255, // Inverte o vermelho
  0, -1, 0, 0, 255, // Inverte o verde
  0, 0, -1, 0, 255, // Inverte o azul
  0, 0, 0, 1, 0, // Mantém o alpha
]);

ColorFilter colorFilterDefault = ColorFilter.matrix([
  1, 0, 0, 0, 0, // Mantém o vermelho
  0, 1, 0, 0, 0, // Mantém o verde
  0, 0, 1, 0, 0, // Mantém o azul
  0, 0, 0, 1, 0, // Mantém o alpha
]);

ColorFilter getColorFilterInverter(bool isInverted) {
  return (isInverted) ? colorFilterInverter : colorFilterDefault;
}
