import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/item.dart';
import '../../_core/components/remove_dialog.dart';
import '../../sheet/providers/sheet_view_model.dart';
import 'shopping_view_model.dart';

abstract class ShoppingInteract {
  static Future<void> removeItem({
    required BuildContext context,
    required String itemId,
    required ShoppingViewModel shoppingVM,
  }) async {
    final sheetVM = context.read<SheetViewModel>();
    Item item = shoppingVM.itemRepo.getItemById(
      itemId,
      listCustomItem: sheetVM.sheet!.listCustomItems,
    )!;

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
    final sheetVM = context.read<SheetViewModel>();
    Item item = shoppingVM.itemRepo.getItemById(
      itemId,
      listCustomItem: sheetVM.sheet!.listCustomItems,
    )!;

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
