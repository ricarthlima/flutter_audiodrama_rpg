import '../../domain/dto/item.dart';

abstract class ItemRepository {
  Future<void> onInitialize();

  List<Item> get listItems;
  List<String> get listCategories;

  Item? getItemById(String id) {
    List<Item> query = listItems.where((element) => element.id == id).toList();

    if (query.isNotEmpty) {
      return query[0];
    }

    return null;
  }
}
