import 'dart:math';

class ExhaustLevel {
  static const List<String> _exhaustLevel = [
    "Disposição",
    "Cansaço",
    "Fadiga",
    "Exaustão",
  ];

  static String getByExhaustLevel(int stressLevel) {
    return _exhaustLevel[min(stressLevel ~/ 4, 3)];
  }

  static int get total => _exhaustLevel.length;
}
