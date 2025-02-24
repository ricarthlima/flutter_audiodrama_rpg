import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../view/shopping_view_model.dart';

class ItemWidget extends StatelessWidget {
  final bool isSeller;
  final Item item;
  final ItemSheet? itemSheet;

  const ItemWidget({
    super.key,
    required this.isSeller,
    required this.item,
    this.itemSheet,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingViewModel = Provider.of<ShoppingViewModel>(context);

    return Column(
      children: [
        ListTile(
          leading: (shoppingViewModel.isBuying)
              ? Visibility(
                  visible: isSeller,
                  child: IconButton(
                    onPressed: () => shoppingViewModel.buyItem(item),
                    tooltip: "Comprar",
                    color: Colors.green[900],
                    iconSize: 48,
                    icon: Icon(Icons.keyboard_arrow_left),
                  ),
                )
              : null,
          title: Text(
            (!isSeller && itemSheet != null)
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
                  Visibility(
                    visible: item.isFinite,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("•"),
                    ),
                  ),
                  Visibility(
                    visible: item.isFinite,
                    child: Tooltip(
                        message: "Máximo de usos", child: Icon(Icons.numbers)),
                  ),
                  Visibility(
                    visible: item.isFinite,
                    child: Text(
                      item.maxUses.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          ),
          trailing: (shoppingViewModel.isBuying)
              ? Visibility(
                  visible: !isSeller,
                  child: IconButton(
                    onPressed: () => shoppingViewModel.sellItem(item.id),
                    tooltip: "Vender",
                    color: Colors.red[900],
                    iconSize: 48,
                    icon: Icon(Icons.keyboard_arrow_right),
                  ),
                )
              : null,
        ),
        Divider()
      ],
    );
  }
}
