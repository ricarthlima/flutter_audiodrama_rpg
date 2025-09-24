abstract class InputValidators {
  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Obrigatório';
    return null;
  }

  static String? positiveInt(String? v, {int min = 1, int? max}) {
    if (v == null || v.trim().isEmpty) return 'Obrigatório';
    final intVal = int.tryParse(v);
    if (intVal == null) return 'Apenas números inteiros';
    if (intVal < min) return 'Mínimo $min';
    if (max != null && intVal > max) return 'Máximo $max';
    return null;
  }
}
