import '../repositories/condition_repository.dart';
import 'remote_mixin.dart';

import '../../domain/dto/condition.dart';

class ConditionRepositoryRemote extends ConditionRepository
    with RemoteMixin<Condition> {
  @override
  String get key => "conditions";

  @override
  Condition fromMap(Map<String, dynamic> map) => Condition.fromMap(map);

  @override
  List<Condition> getAll() => List.unmodifiable(cachedList);

  @override
  Future<void> onInitialize() async {
    await remoteInitialize();
  }
}
