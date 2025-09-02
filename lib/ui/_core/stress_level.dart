class StressLevel {
  static const List<String> _stressLevel = [
    "Saudável",
    "Tensão",
    "Estresse",
    "Desespero",
  ];

  static String getByStressLevel(int stressPoints) {
    return _stressLevel[stressPoints ~/ 4];
  }

  static int get total => _stressLevel.length;
}
