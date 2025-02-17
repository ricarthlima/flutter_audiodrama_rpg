import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/data/item_dao.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/item_sheet.dart';

import '../../models/item.dart';

showShoppingDialog(
  BuildContext context, {
  required bool isEditing,
  required List<ItemSheet> listSheetItems,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        child: Stack(
          children: [
            Container(
              height: height(context),
              width: width(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: (isEditing)
                  ? Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 32,
                      children: [
                        _ShoppingWidget(
                          isSeller: false,
                          isEditing: isEditing,
                        ),
                        _ShoppingWidget(
                          isSeller: true,
                          isEditing: isEditing,
                        ),
                      ],
                    )
                  : _ShoppingWidget(
                      isSeller: false,
                      isEditing: isEditing,
                    ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  iconSize: 32,
                  icon: Icon(Icons.close),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

class _ShoppingWidget extends StatefulWidget {
  final bool isSeller;
  final bool isEditing;
  const _ShoppingWidget({
    required this.isSeller,
    required this.isEditing,
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
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: (listItem.isEmpty)
                ? Center(
                    child: Text(
                      "Ainda não comprou nada?",
                      style: TextStyle(fontSize: 24),
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
                          );
                        },
                      ),
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
  const _ShoppingItemWidget({
    required this.item,
    required this.isSeller,
    required this.isEditing,
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
                    onPressed: () {},
                    tooltip: "Comprar",
                    color: Colors.green[900],
                    iconSize: 48,
                    icon: Icon(Icons.keyboard_arrow_left),
                  ),
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
                    onPressed: () {},
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
