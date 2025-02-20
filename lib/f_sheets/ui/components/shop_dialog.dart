import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/_core/helpers.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/data/item_dao.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/item_sheet.dart';

import '../../models/item.dart';

Future<dynamic> showShoppingDialog(
  BuildContext context, {
  required bool isEditing,
  required List<ItemSheet> listSheetItems,
  required int trainLevel,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        child: _ShoppingDialogScreen(
          listSheetItems: listSheetItems,
          isEditing: isEditing,
          trainLevel: trainLevel,
        ),
      );
    },
  );
}

class _ShoppingDialogScreen extends StatefulWidget {
  final bool isEditing;
  final List<ItemSheet> listSheetItems;
  final int trainLevel;

  const _ShoppingDialogScreen({
    required this.listSheetItems,
    required this.isEditing,
    required this.trainLevel,
  });

  @override
  State<_ShoppingDialogScreen> createState() => _ShoppingDialogScreenState();
}

class _ShoppingDialogScreenState extends State<_ShoppingDialogScreen> {
  int totalScore = 0;
  int totalSpent = 0;

  @override
  void initState() {
    _calculateSpent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height(context),
          width: width(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (widget.isEditing)
                  ? Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 32,
                      spacing: 32,
                      children: [
                        _ShoppingWidget(
                          isSeller: false,
                          isEditing: widget.isEditing,
                          onBuyClicked: (item) => _buyItem(item),
                          onSellClicked: (itemId) => _sellItem(itemId),
                          listSheetItems: widget.listSheetItems,
                        ),
                        _ShoppingWidget(
                          isSeller: true,
                          isEditing: widget.isEditing,
                          onBuyClicked: (item) => _buyItem(item),
                          onSellClicked: (itemId) => _sellItem(itemId),
                          listSheetItems: widget.listSheetItems,
                        ),
                      ],
                    )
                  : _ShoppingWidget(
                      isSeller: false,
                      isEditing: widget.isEditing,
                      onBuyClicked: (item) => _buyItem(item),
                      onSellClicked: (itemId) => _sellItem(itemId),
                      listSheetItems: widget.listSheetItems,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "\$ $totalSpent",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: (totalSpent > totalScore) ? Colors.red[700] : null,
                    ),
                  ),
                  Text(
                    "/$totalScore",
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context, widget.listSheetItems);
              },
              iconSize: 32,
              icon: Icon(Icons.close),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: width(context) * 0.5,
            height: 4,
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(175),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(""),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1250),
            width: (width(context) * 0.5) * min(1, (totalSpent / totalScore)),
            height: 4,
            margin: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.red[900]!,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(""),
          ),
        ),
      ],
    );
  }

  _buyItem(Item item) {
    if (widget.listSheetItems.where((e) => e.itemId == item.id).isNotEmpty) {
      widget.listSheetItems.where((e) => e.itemId == item.id).first.amount++;
    } else {
      widget.listSheetItems.add(
        ItemSheet(itemId: item.id, uses: 0, amount: 1),
      );
    }
    _calculateSpent();
    setState(() {});
  }

  _sellItem(String itemId) {
    widget.listSheetItems.where((e) => e.itemId == itemId).first.amount--;
    if (widget.listSheetItems.where((e) => e.itemId == itemId).first.amount <=
        0) {
      widget.listSheetItems.removeWhere((e) => e.itemId == itemId);
    }
    _calculateSpent();
    setState(() {});
  }

  void _calculateSpent() {
    totalScore = getCreditByLevel(widget.trainLevel);
    totalSpent = (widget.listSheetItems.isEmpty)
        ? 0
        : widget.listSheetItems.map(
            (e) {
              int price = ItemDAO.instance.getItemById(e.itemId)!.price;
              return price * e.amount;
            },
          ).reduce((v, e) => v + e);
  }
}

class _ShoppingWidget extends StatefulWidget {
  final bool isSeller;
  final bool isEditing;
  final Function(Item item) onBuyClicked;
  final Function(String itemId) onSellClicked;
  final List<ItemSheet> listSheetItems;

  const _ShoppingWidget({
    required this.isSeller,
    required this.isEditing,
    required this.onBuyClicked,
    required this.onSellClicked,
    required this.listSheetItems,
  });

  @override
  State<_ShoppingWidget> createState() => __ShoppingWidgetState();
}

class __ShoppingWidgetState extends State<_ShoppingWidget> {
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
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 32,
          children: [
            Text(
              widget.isSeller ? "Comprar" : "Seus itens",
              style: TextStyle(
                fontSize: 20,
                fontFamily: FontFamilies.bungee,
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
          width: !widget.isEditing
              ? null
              : isVertical(context)
                  ? width(context) * 0.8
                  : width(context) / 2 - 100,
          height: height(context) * 0.8,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                width: 4,
                color: Theme.of(context).textTheme.bodyMedium!.color!),
          ),
          child: (!widget.isSeller)
              ? (widget.listSheetItems.isEmpty)
                  ? Center(
                      child: Text(
                        "Ainda não comprou nada?",
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                          widget.listSheetItems.length,
                          (index) {
                            ItemSheet itemSheet = widget.listSheetItems[index];
                            Item item =
                                ItemDAO.instance.getItemById(itemSheet.itemId)!;
                            return _ShoppingItemWidget(
                              item: item,
                              isSeller: widget.isSeller,
                              isEditing: widget.isEditing,
                              onBuyButtonClicked: (item) =>
                                  widget.onBuyClicked(item),
                              onSellButtonClicked: (itemId) =>
                                  widget.onSellClicked(itemId),
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
                        return _ShoppingItemWidget(
                          item: item,
                          isSeller: widget.isSeller,
                          isEditing: widget.isEditing,
                          onBuyButtonClicked: (item) =>
                              widget.onBuyClicked(item),
                          onSellButtonClicked: (itemId) =>
                              widget.onSellClicked(itemId),
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

class _ShoppingItemWidget extends StatelessWidget {
  final Item item;
  final bool isSeller;
  final bool isEditing;
  final Function(Item item) onBuyButtonClicked;
  final Function(String itemId) onSellButtonClicked;
  final ItemSheet? itemSheet;

  const _ShoppingItemWidget({
    required this.item,
    required this.isSeller,
    required this.isEditing,
    required this.onBuyButtonClicked,
    required this.onSellButtonClicked,
    this.itemSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: (isEditing)
              ? Visibility(
                  visible: isSeller,
                  child: IconButton(
                    onPressed: () => onBuyButtonClicked(item),
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
          trailing: (isEditing)
              ? Visibility(
                  visible: !isSeller,
                  child: IconButton(
                    onPressed: () => onSellButtonClicked(item.id),
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
