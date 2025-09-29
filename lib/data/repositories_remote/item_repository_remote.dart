import 'dart:convert';

import '../repositories/item_repository.dart';
import 'remote_mixin.dart';
import '../../domain/dto/item.dart';

import '../../_core/helpers/print.dart';
import '../../ui/_core/utils/i18n_categories.dart';

class ItemRepositoryRemote extends ItemRepository with RemoteMixin<Item> {
  @override
  Item fromMap(Map<String, dynamic> map) => Item.fromMap(map);

  @override
  String get key => "items";

  @override
  List<String> get listCategories => List.unmodifiable(_cachedCategories);

  @override
  List<Item> get listItems => List.unmodifiable(cachedList);

  final List<String> _cachedCategories = [];

  @override
  Future<void> onInitialize() async {
    String? jsonString = await remoteInitialize(populateMyself: true);

    if (jsonString != null) {
      printD("[POPULATING TO MEMORY] $key");
      Map<String, dynamic> jsonData = json.decode(jsonString);

      cachedList = (jsonData["items"] as List<dynamic>)
          .map((e) => Item.fromMap(e))
          .toList();

      for (Item item in cachedList) {
        for (String category in item.listCategories) {
          if (!listCategories.contains(category)) {
            _cachedCategories.add(category);
          }
        }
        _cachedCategories.sort((a, b) {
          String iA = i18nCategories(a);
          String iB = i18nCategories(b);
          return iA.compareTo(iB);
        });
      }
      printD("[POPULATED] $key");
    }
  }
}
