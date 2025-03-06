import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/utils/i18n_categories.dart';

import '../../domain/models/item.dart';

class ItemDAO {
  static const String _filePath = 'assets/sheets/itens-0.0.5.json';

  List<Item> _listItems = [];
  final List<String> _listCategories = [];

  ItemDAO._();

  static final ItemDAO _instance = ItemDAO._();
  static ItemDAO get instance {
    return _instance;
  }

  List<String> get listCategories => _listCategories;

  Future<void> initialize() async {
    String jsonString = await rootBundle.loadString(_filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);

    _listItems = (jsonData["items"] as List<dynamic>)
        .map((e) => Item.fromMap(e))
        .toList();

    int total = _listItems.map((e) => e.price).toList().reduce((v, e) => v + e);
    print(
        "${_listItems.length} itens carregados, custando um total de: $total");

    for (Item item in _listItems) {
      for (String category in item.listCategories) {
        if (!_listCategories.contains(category)) {
          _listCategories.add(category);
        }
      }
    }

    _listCategories.sort(
      (a, b) {
        String iA = i18nCategories(a);
        String iB = i18nCategories(b);
        return iA.compareTo(iB);
      },
    );

    print(_listCategories);
  }

  List<Item> get getItems {
    return _listItems;
  }

  Item? getItemById(String id) {
    List<Item> query = _listItems
        .where(
          (element) => element.id == id,
        )
        .toList();

    if (query.isNotEmpty) {
      return query[0];
    }

    return null;
  }
}
