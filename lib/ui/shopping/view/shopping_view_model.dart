import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/item_sheet.dart';

import '../../../domain/models/item.dart';

class ShoppingViewModel extends ChangeNotifier {
  bool _isBuying = false;

  bool get isBuying => _isBuying;

  set isBuying(bool value) {
    _isBuying = value;
    notifyListeners();
  }

  toggleBuying() {
    _isBuying = !_isBuying;
    notifyListeners();
  }

  List<ItemSheet> listSheetItems = [];

  buyItem(Item item) {
    if (listSheetItems.where((e) => e.itemId == item.id).isNotEmpty) {
      listSheetItems.where((e) => e.itemId == item.id).first.amount++;
    } else {
      listSheetItems.add(
        ItemSheet(itemId: item.id, uses: 0, amount: 1),
      );
    }
    notifyListeners();
  }

  sellItem(String itemId) {
    listSheetItems.where((e) => e.itemId == itemId).first.amount--;
    if (listSheetItems.where((e) => e.itemId == itemId).first.amount <= 0) {
      listSheetItems.removeWhere((e) => e.itemId == itemId);
    }
    notifyListeners();
  }

  openInventory(List<ItemSheet> listItems) {
    listSheetItems = listItems;
    isBuying = false;
    notifyListeners();
  }
}
