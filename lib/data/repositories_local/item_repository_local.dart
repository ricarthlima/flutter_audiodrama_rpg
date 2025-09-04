import 'dart:convert';

import 'package:flutter/services.dart';
import '../repositories/item_repository.dart';
import '../../ui/_core/utils/i18n_categories.dart';

import '../../domain/dto/item.dart';

class ItemRepositoryLocal extends ItemRepository {
  static const String _filePath = 'assets/sheets/items.json';

  List<Item> _cachedItems = [];
  final List<String> _cachedCategories = [];

  @override
  Future<void> onInitialize() async {
    String jsonString = await rootBundle.loadString(_filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedItems = (jsonData["items"] as List<dynamic>)
        .map((e) => Item.fromMap(e))
        .toList();

    // int total =
    //     _cachedItems.map((e) => e.price).toList().reduce((v, e) => v + e);
    // Logger().i(
    //     "${_cachedItems.length} itens carregados, custando um total de: $total");

    for (Item item in _cachedItems) {
      for (String category in item.listCategories) {
        if (!listCategories.contains(category)) {
          _cachedCategories.add(category);
        }
      }
    }

    _cachedCategories.sort((a, b) {
      String iA = i18nCategories(a);
      String iB = i18nCategories(b);
      return iA.compareTo(iB);
    });

    // Logger().i(_cachedCategories);
  }

  @override
  List<Item> get listItems => List.unmodifiable(_cachedItems);

  @override
  List<String> get listCategories => List.unmodifiable(_cachedCategories);
}
