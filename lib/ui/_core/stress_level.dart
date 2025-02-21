class StressLevel {
  static const List<String> _stressLevel = [
    "Saudável",
    "Tensão",
    "Estresse",
    "Desespero",
  ];
  String getByStressLevel(int stressLevel) {
    return _stressLevel[stressLevel];
  }

  static int get total => _stressLevel.length;
}
