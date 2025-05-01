import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/utils/i18n_categories.dart';
import '../view/shopping_view_model.dart';

class ItemSellerWidget extends StatelessWidget {
  final Item item;
  final ItemSheet? itemSheet;

  const ItemSellerWidget({
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
          leading: (shoppingViewModel.isBuying)
              ? IconButton(
                  onPressed: () => shoppingViewModel.buyItem(item: item),
                  tooltip: "Comprar",
                  color: Colors.green[900],
                  iconSize: 48,
                  icon: Icon(Icons.keyboard_arrow_left),
                )
              : null,
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: item.listCategories
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(
                            i18nCategories(e),
                            style: TextStyle(fontSize: 10),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 8),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (item.isFinite)
                      Row(
                        spacing: 8,
                        children: [
                          Tooltip(
                            message: "Máximo de usos",
                            child: Icon(Icons.numbers),
                          ),
                          Text(
                            (item.maxUses ?? 0).toString(),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("•"),
                          ),
                        ],
                      ),
                    Tooltip(
                        message: "Preço",
                        child: Icon(Icons.attach_money_sharp)),
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
                ),
              )
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
