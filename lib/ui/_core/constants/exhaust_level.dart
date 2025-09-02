class ExhaustLevel {
  static const List<String> _exhaustLevel = [
    "Disposição",
    "Cansaço",
    "Fadiga",
    "Exaustão",
  ];

  static String getByExhaustLevel(int stressLevel) {
    return _exhaustLevel[stressLevel ~/ 4];
  }

  static int get total => _exhaustLevel.length;
}
