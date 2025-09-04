import '../../domain/dto/spell.dart';

abstract class SpellRepository {
  Future<void> onInitialize();
  List<Spell> getAll();
}
