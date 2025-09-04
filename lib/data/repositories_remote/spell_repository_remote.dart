import 'package:flutter_rpg_audiodrama/data/repositories_remote/remote_mixin.dart';
import 'package:flutter_rpg_audiodrama/domain/dto/spell.dart';

import '../repositories/spell_repository.dart';

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
  }
}
