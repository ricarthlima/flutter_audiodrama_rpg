import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../view/shopping_view_model.dart';

class ItemInventoryWidget extends StatelessWidget {
  final Item item;
  final ItemSheet? itemSheet;

  const ItemInventoryWidget({
    super.key,
    required this.item,
    this.itemSheet,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingViewModel = Provider.of<ShoppingViewModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            (itemSheet != null)
                ? "${item.name} (x${itemSheet!.amount})"
                : item.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              Text(
                item.mechanic,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Visibility(
                visible: item.isFinite,
                child: Text(
                  "Máximo de usos: ${item.maxUses}",
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (item.isFinite)
                    Row(
                      spacing: 8,
                      children: [
                        Tooltip(
                          message: "Usos restantes",
                          child: Icon(Icons.numbers),
                        ),
                        Text(
                          _getTotalAmount(
                            shoppingViewModel.listSheetItems
                                .firstWhere((e) => e.itemId == item.id)
                                .uses,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("•"),
                        ),
                      ],
                    ),
                  Tooltip(
                      message: "Preço", child: Icon(Icons.attach_money_sharp)),
                  Text(
                    item.price.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("•"),
                  ),
                  Tooltip(message: "Peso", child: Icon(Icons.fitness_center)),
                  Text(
                    item.weight.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            ],
          ),
          trailing: (shoppingViewModel.isBuying)
              ? IconButton(
                  onPressed: () => shoppingViewModel.sellItem(
                    context: context,
                    itemId: item.id,
                  ),
                  tooltip: "Vender",
                  color: AppColors.red,
                  iconSize: 48,
                  icon: Icon(Icons.keyboard_arrow_right),
                )
              : null,
        ),
        if (!shoppingViewModel.isBuying)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.isFinite)
                    TextButton(
                      onPressed: () => shoppingViewModel.useItem(
                        context: context,
                        itemId: item.id,
                      ),
                      child: Text("Usar"),
                    ),
                  if (item.isFinite)
                    TextButton(
                      onPressed: () => shoppingViewModel.reloadUses(
                        context: context,
                        itemId: item.id,
                      ),
                      child: Text("Recarregar usos"),
                    ),
                  TextButton(
                    onPressed: () => shoppingViewModel.removeItem(
                      context: context,
                      itemId: item.id,
                    ),
                    child: Text("Remover"),
                  ),
                  TextButton(
                    onPressed: () => shoppingViewModel.removeAllFromItem(
                      context: context,
                      itemId: item.id,
                    ),
                    child: Text("Remover tudo"),
                  ),
                ],
              ),
            ),
          ),
        Divider()
      ],
    );
  }

  String _getTotalAmount(int currentAmount) {
    return "${item.maxUses! - currentAmount} usos restantes";
  }
}
