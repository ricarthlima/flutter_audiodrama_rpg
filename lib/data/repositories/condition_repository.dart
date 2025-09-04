import '../../domain/dto/condition.dart';

abstract class ConditionRepository {
  Future<void> onInitialize();
  List<Condition> getAll();

  List<Condition> get getConditions {
    List<Condition> listSorted = getAll();

    listSorted.sort((a, b) => a.showingOrder.compareTo(b.showingOrder));
    return listSorted;
  }

  Condition? getConditionById(String id) {
    List<Condition> query = getAll().where((e) => e.id == id).toList();
    if (query.isNotEmpty) {
      return query[0];
    }
    return null;
  }
}
