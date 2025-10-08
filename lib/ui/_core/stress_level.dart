import 'dart:math';

class StressLevel {
  static const List<String> _stressLevel = [
    "Saudável",
    "Tensão",
    "Estresse",
    "Desespero",
  ];

  static String getByStressLevel(int stressPoints) {
    return _stressLevel[min(stressPoints ~/ 4, 3)];
  }

  static int get total => _stressLevel.length;
}
