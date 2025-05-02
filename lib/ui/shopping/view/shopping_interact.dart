import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/item.dart';
import '../../_core/components/remove_dialog.dart';

abstract class ShoppingInteract {
  static Future<void> removeItem({
    required BuildContext context,
    required String itemId,
  }) async {
    Item item = context.read<ShoppingViewModel>().itemRepo.getItemById(itemId)!;

    bool? result = await showRemoveItemDialog(
      context: context,
      name: item.name,
    );

    if (result != null && result) {
      if (!context.mounted) return;
      context.read<ShoppingViewModel>().removeItem(itemId: itemId);
    }
  }

  static Future<void> removeAllFromItem({
    required BuildContext context,
    required String itemId,
    bool isOver = false,
  }) async {
    Item item = context.read<ShoppingViewModel>().itemRepo.getItemById(itemId)!;

    bool? result = await showRemoveItemDialog(
      context: context,
      name: item.name,
      isOver: isOver,
    );

    if (result != null && result) {
      if (!context.mounted) return;
      context.read<ShoppingViewModel>().removeAllFromItem(itemId: itemId);
    }
  }
}
