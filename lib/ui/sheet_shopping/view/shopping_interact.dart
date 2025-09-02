import 'package:flutter/material.dart';
import 'shopping_view_model.dart';
import '../../../domain/models/item.dart';
import '../../_core/components/remove_dialog.dart';

abstract class ShoppingInteract {
  static Future<void> removeItem({
    required BuildContext context,
    required String itemId,
    required ShoppingViewModel shoppingVM,
  }) async {
    Item item = shoppingVM.itemRepo.getItemById(itemId)!;

    bool? result = await showRemoveItemDialog(
      context: context,
      name: item.name,
    );

    if (result != null && result) {
      shoppingVM.removeItem(itemId: itemId);
    }
  }

  static Future<void> removeAllFromItem({
    required BuildContext context,
    required String itemId,
    required ShoppingViewModel shoppingVM,
    bool isOver = false,
  }) async {
    Item item = shoppingVM.itemRepo.getItemById(itemId)!;

    bool? result = await showRemoveItemDialog(
      context: context,
      name: item.name,
      isOver: isOver,
    );

    if (result != null && result) {
      shoppingVM.removeAllFromItem(itemId: itemId);
    }
  }
}
