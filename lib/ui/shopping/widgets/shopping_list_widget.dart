import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/daos/item_dao.dart';
import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../view/shopping_view_model.dart';
import 'item_widget.dart';

class ShoppingListWidget extends StatefulWidget {
  final bool isSeller;

  const ShoppingListWidget({
    super.key,
    required this.isSeller,
  });

  @override
  State<ShoppingListWidget> createState() => _ShoppingListWidgetState();
}

class _ShoppingListWidgetState extends State<ShoppingListWidget> {
  List<Item> listItem = [];

  bool isOrderedByName = true;
  bool isOrderedByPrice = false;
  bool isAscendent = true;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingViewModel = Provider.of<ShoppingViewModel>(context);

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 32,
          children: [
            Text(
              widget.isSeller ? "Comprar" : "Seus itens",
              style: TextStyle(
                fontSize: 20,
                fontFamily: FontFamily.bungee,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (isOrderedByName) {
                      isAscendent = !isAscendent;
                    } else {
                      isOrderedByName = true;
                      isOrderedByPrice = false;
                      isAscendent = true;
                    }
                    _orderItems();
                  },
                  tooltip: "Ordenar por nome",
                  icon: Icon(Icons.sort_by_alpha),
                ),
                IconButton(
                  onPressed: () {
                    if (isOrderedByPrice) {
                      isAscendent = !isAscendent;
                    } else {
                      isOrderedByPrice = true;
                      isOrderedByName = false;
                      isAscendent = true;
                    }
                    _orderItems();
                  },
                  tooltip: "Ordenar por preço",
                  icon: Icon(Icons.sort),
                ),
              ],
            )
          ],
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight:
                height(context) - 200, // Define um limite máximo de altura
          ),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                width: 4,
                color: Theme.of(context).textTheme.bodyMedium!.color!),
          ),
          child: (!widget.isSeller)
              ? (shoppingViewModel.listSheetItems.isEmpty)
                  ? Center(
                      child: Text(
                        "Mochila vazia",
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          shoppingViewModel.listSheetItems.length,
                          (index) {
                            ItemSheet itemSheet =
                                shoppingViewModel.listSheetItems[index];
                            Item item =
                                ItemDAO.instance.getItemById(itemSheet.itemId)!;
                            return ItemWidget(
                              item: item,
                              isSeller: widget.isSeller,
                              itemSheet: itemSheet,
                            );
                          },
                        ),
                      ),
                    )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      listItem.length,
                      (index) {
                        Item item = listItem[index];
                        return ItemWidget(
                          item: item,
                          isSeller: widget.isSeller,
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _loadItems() async {
    if (widget.isSeller) {
      listItem = ItemDAO.instance.getItems;
    }
    _orderItems();
  }

  _orderItems() {
    if (isOrderedByName) {
      listItem.sort((a, b) => a.name.compareTo(b.name));
      if (!isAscendent) {
        listItem = listItem.reversed.toList();
      }
    }

    if (isOrderedByPrice) {
      listItem.sort((a, b) => a.price.compareTo(b.price));
      if (!isAscendent) {
        listItem = listItem.reversed.toList();
      }
    }
    setState(() {});
  }
}
