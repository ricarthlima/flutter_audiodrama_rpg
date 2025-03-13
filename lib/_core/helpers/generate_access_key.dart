import 'dart:math';

String generateAccessKey() {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random random = Random();

  String generateSegment(int length) {
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  return '${generateSegment(4)}-${generateSegment(4)}';
}
