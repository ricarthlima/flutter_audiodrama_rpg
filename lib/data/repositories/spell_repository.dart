import '../../domain/dto/spell.dart';

abstract class SpellRepository {
  Future<void> onInitialize();
  List<Spell> getAll();

  Spell? getById(String id) {
    if (getAll().where((e) => e.name == id).isNotEmpty) {
      return getAll().where((e) => e.name == id).first;
    }
    return null;
  }
}
