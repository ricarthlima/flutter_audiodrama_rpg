import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/helpers.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/widgets/item_seller_widget.dart';
import 'package:provider/provider.dart';

import '../../../data/daos/item_dao.dart';
import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../view/shopping_view_model.dart';
import 'item_inventory_widget.dart';

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
  bool isOrderedByWeight = false;
  bool isOrderedByAmount = false;
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
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (isOrderedByName) {
                          isAscendent = !isAscendent;
                        } else {
                          isOrderedByName = true;
                          isOrderedByPrice = false;
                          isOrderedByWeight = false;
                          isOrderedByAmount = false;
                          isAscendent = true;
                        }
                        _orderItems();
                        _orderItemsMine();
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
                          isOrderedByWeight = false;
                          isOrderedByAmount = false;
                          isAscendent = true;
                        }
                        _orderItems();
                        _orderItemsMine();
                      },
                      tooltip: "Ordenar por preço",
                      icon: Icon(Icons.attach_money_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        if (isOrderedByWeight) {
                          isAscendent = !isAscendent;
                        } else {
                          isOrderedByWeight = true;
                          isOrderedByPrice = false;
                          isOrderedByName = false;
                          isOrderedByAmount = false;
                          isAscendent = true;
                        }
                        _orderItems();
                        _orderItemsMine();
                      },
                      tooltip: "Ordenar por peso",
                      icon: Icon(Icons.fitness_center_rounded),
                    ),
                    if (!widget.isSeller)
                      IconButton(
                        onPressed: () {
                          if (isOrderedByWeight) {
                            isAscendent = !isAscendent;
                          } else {
                            isOrderedByAmount = true;
                            isOrderedByWeight = false;
                            isOrderedByPrice = false;
                            isOrderedByName = false;
                            isAscendent = true;
                          }
                          _orderItems();
                          _orderItemsMine();
                        },
                        tooltip: "Ordenar por quantidade",
                        icon: Icon(Icons.numbers),
                      ),
                    if (widget.isSeller)
                      SizedBox(
                        width: 120,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CheckboxListTile(
                            value: shoppingViewModel.isFree,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text("De graça"),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              shoppingViewModel.isFree =
                                  !shoppingViewModel.isFree;
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight:
                height(context) - 220, // Define um limite máximo de altura
          ),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                width: 1,
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
                            return ItemInventoryWidget(
                              item: item,
                              itemSheet: itemSheet,
                            );
                          },
                        ),
                      ),
                    )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      listItem.length,
                      (index) {
                        Item item = listItem[index];
                        return ItemSellerWidget(item: item);
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
    _orderItemsMine();
  }

  _orderItems() {
    if (isOrderedByName) {
      listItem.sort(
        (a, b) => removeDiacritics(a.name).compareTo(
          removeDiacritics(b.name),
        ),
      );
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

    if (isOrderedByWeight) {
      listItem.sort((a, b) => a.weight.compareTo(b.weight));
      if (!isAscendent) {
        listItem = listItem.reversed.toList();
      }
    }

    setState(() {});
  }

  _orderItemsMine() {
    final shoppingViewModel = context.read<ShoppingViewModel>();

    if (isOrderedByName) {
      shoppingViewModel.listSheetItems.sort((a, b) {
        Item itemA = ItemDAO.instance.getItemById(a.itemId)!;
        Item itemB = ItemDAO.instance.getItemById(b.itemId)!;
        return removeDiacritics(itemA.name).compareTo(
          removeDiacritics(itemB.name),
        );
      });
      if (!isAscendent) {
        shoppingViewModel.listSheetItems =
            shoppingViewModel.listSheetItems.reversed.toList();
      }
    }

    if (isOrderedByPrice) {
      shoppingViewModel.listSheetItems.sort((a, b) {
        Item itemA = ItemDAO.instance.getItemById(a.itemId)!;
        Item itemB = ItemDAO.instance.getItemById(b.itemId)!;
        return itemA.price.compareTo(itemB.price);
      });
      if (!isAscendent) {
        shoppingViewModel.listSheetItems =
            shoppingViewModel.listSheetItems.reversed.toList();
      }
    }

    if (isOrderedByWeight) {
      shoppingViewModel.listSheetItems.sort((a, b) {
        Item itemA = ItemDAO.instance.getItemById(a.itemId)!;
        Item itemB = ItemDAO.instance.getItemById(b.itemId)!;
        return itemA.weight.compareTo(itemB.weight);
      });
      if (!isAscendent) {
        shoppingViewModel.listSheetItems =
            shoppingViewModel.listSheetItems.reversed.toList();
      }
    }

    if (isOrderedByAmount) {
      shoppingViewModel.listSheetItems
          .sort((a, b) => a.amount.compareTo(b.amount));
      if (!isAscendent) {
        shoppingViewModel.listSheetItems =
            shoppingViewModel.listSheetItems.reversed.toList();
      }
    }
    setState(() {});
  }
}
