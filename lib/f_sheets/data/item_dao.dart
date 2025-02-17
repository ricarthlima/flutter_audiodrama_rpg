import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/item.dart';

class ItemDAO {
  static const String _filePath = 'assets/sheets/itens-0.0.2.json';

  List<Item> _listItems = [];

  ItemDAO._();

  static final ItemDAO _instance = ItemDAO._();
  static ItemDAO get instance {
    return _instance;
  }

  Future<void> initialize() async {
    String jsonString = await rootBundle.loadString(_filePath);
    Map<String, dynamic> jsonData = json.decode(jsonString);

    _listItems = (jsonData["items"] as List<dynamic>)
        .map((e) => Item.fromMap(e))
        .toList();

    print("${_listItems.length} itens carregados");
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
