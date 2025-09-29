import '../../domain/dto/spell.dart';
import '../repositories/spell_repository.dart';
import 'remote_mixin.dart';

class SpellRepositoryRemote extends SpellRepository with RemoteMixin<Spell> {
  @override
  final String key = "spells";

  @override
  Spell fromMap(Map<String, dynamic> map) => Spell.fromMap(map);

  @override
  List<Spell> getAll() => List.unmodifiable(cachedList);

  @override
  Future<void> onInitialize() async {
    await remoteInitialize();
    super.cachedList.sort((a, b) => a.energy.compareTo(b.energy));
  }
}
