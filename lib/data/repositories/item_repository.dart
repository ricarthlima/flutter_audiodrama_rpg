import '../../domain/dto/item.dart';

abstract class ItemRepository {
  Future<void> onInitialize();

  List<Item> get listItems;
  List<String> get listCategories;

  Item? getItemById(String id, {required List<Item> listCustomItem}) {
    List<Item> listQuery = listItems + listCustomItem;
    List<Item> query = listQuery.where((element) => element.id == id).toList();

    if (query.isNotEmpty) {
      return query[0];
    }

    return null;
  }
}
