import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/helpers.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/widgets/item_category_widget.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/widgets/item_seller_widget.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../sheet/view/sheet_view_model.dart';
import '../view/shopping_view_model.dart';
import 'item_inventory_widget.dart';

class ShoppingListWidget extends StatefulWidget {
  final bool isSeller;

  const ShoppingListWidget({super.key, required this.isSeller});

  @override
  State<ShoppingListWidget> createState() => _ShoppingListWidgetState();
}

class _ShoppingListWidgetState extends State<ShoppingListWidget> {
  bool isOrderedByName = true;
  bool isOrderedByPrice = false;
  bool isOrderedByWeight = false;
  bool isOrderedByAmount = false;
  bool isAscendent = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadItems();
      },
    );
  }

  Row _buildToggleStore(ShoppingViewModel shoppingVM, SheetViewModel sheetVM,
      BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        VerticalDivider(
          thickness: 1,
        ),
        if (!shoppingVM.isBuying)
          Text(
            "\$ ${sheetVM.sheet!.money}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (shoppingVM.isBuying)
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: shoppingVM.getMoneyTextController(sheetVM),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.attach_money_rounded,
                  color: shoppingVM.showingHaveNoMoney ? AppColors.red : null,
                ),
                suffix: InkWell(
                  onTap: (shoppingVM.isShowingMoneyFeedback == null)
                      ? () {
                          shoppingVM.onEditingMoney();
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      (shoppingVM.isShowingMoneyFeedback == null)
                          ? Icons.save
                          : (shoppingVM.isShowingMoneyFeedback!)
                              ? Icons.check
                              : Icons.error,
                      size: 18,
                    ),
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: shoppingVM.showingHaveNoMoney ? AppColors.red : null,
              ),
            ),
          ),
        if (!isVertical(context) && sheetVM.isOwner)
          OutlinedButton(
            onPressed: () {
              shoppingVM.toggleBuying();
            },
            child: Text(
              shoppingVM.isBuying ? "Fechar loja" : "Abrir loja",
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);
    final shoppingVM = Provider.of<ShoppingViewModel>(context);

    return Consumer<ShoppingViewModel>(builder: (context, value, child) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _orderItems();
          _orderItemsMine();
        },
      );
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CheckboxListTile(
                              value: shoppingVM.isFree,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              title: Text("De graça"),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                shoppingVM.isFree = !shoppingVM.isFree;
                              },
                            ),
                          ),
                        ),
                      if (!widget.isSeller)
                        _buildToggleStore(shoppingVM, sheetVM, context),
                    ],
                  ),
                ),
              )
            ],
          ),
          TextFormField(
            controller: !widget.isSeller
                ? shoppingVM.searchInventoryController
                : shoppingVM.searchSellerController,
            decoration: InputDecoration(
              label: Text("Pesquisar item"),
              suffix: InkWell(
                onTap: () => (widget.isSeller)
                    ? shoppingVM.onSearchOnSeller()
                    : shoppingVM.onSearchOnInventory(),
                child: Icon(Icons.search),
              ),
            ),
            onFieldSubmitted: (value) => (widget.isSeller)
                ? shoppingVM.onSearchOnSeller()
                : shoppingVM.onSearchOnInventory(),
            onChanged: (value) => (widget.isSeller)
                ? shoppingVM.onSearchOnSeller()
                : shoppingVM.onSearchOnInventory(),
          ),
          Wrap(
            children: context
                .read<ShoppingViewModel>()
                .itemRepo
                .listCategories
                .map((e) {
              return ItemCategoryWidget(
                category: e,
                isSeller: widget.isSeller,
                isActive: (!widget.isSeller)
                    ? shoppingVM.listFilteredCategories.contains(e)
                    : shoppingVM.listFilteredCategoriesSeller.contains(e),
              );
            }).toList(),
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  width: 1,
                  color: Theme.of(context).textTheme.bodyMedium!.color!),
            ),
            child: (!widget.isSeller)
                ? (shoppingVM.listInventoryItems.isEmpty)
                    ? Center(child: Text("Nada por aqui"))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            shoppingVM.listInventoryItems.length,
                            (index) {
                              ItemSheet itemSheet =
                                  shoppingVM.listInventoryItems[index];
                              Item item = context
                                  .read<ShoppingViewModel>()
                                  .itemRepo
                                  .getItemById(itemSheet.itemId)!;
                              return ItemInventoryWidget(
                                item: item,
                                itemSheet: itemSheet,
                              );
                            },
                          ),
                        ),
                      )
                : (shoppingVM.listSellerItems.isEmpty)
                    ? Center(child: Text("Nada por aqui"))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            shoppingVM.listSellerItems.length,
                            (index) {
                              Item item = shoppingVM.listSellerItems[index];
                              return ItemSellerWidget(item: item);
                            },
                          ),
                        ),
                      ),
          ),
        ],
      );
    });
  }

  Future<void> _loadItems() async {
    final shoppingViewModel = context.read<ShoppingViewModel>();
    shoppingViewModel.onSearchOnInventory();
    shoppingViewModel.onSearchOnSeller();
    _orderItems();
    _orderItemsMine();
  }

  _orderItems() {
    final shoppingViewModel = context.read<ShoppingViewModel>();

    if (isOrderedByName) {
      shoppingViewModel.listSellerItems.sort(
        (a, b) => removeDiacritics(a.name).compareTo(
          removeDiacritics(b.name),
        ),
      );
      if (!isAscendent) {
        shoppingViewModel.listSellerItems =
            shoppingViewModel.listSellerItems.reversed.toList();
      }
    }

    if (isOrderedByPrice) {
      shoppingViewModel.listSellerItems
          .sort((a, b) => a.price.compareTo(b.price));
      if (!isAscendent) {
        shoppingViewModel.listSellerItems =
            shoppingViewModel.listSellerItems.reversed.toList();
      }
    }

    if (isOrderedByWeight) {
      shoppingViewModel.listSellerItems
          .sort((a, b) => a.weight.compareTo(b.weight));
      if (!isAscendent) {
        shoppingViewModel.listSellerItems =
            shoppingViewModel.listSellerItems.reversed.toList();
      }
    }

    setState(() {});
  }

  _orderItemsMine() {
    final shoppingViewModel = context.read<ShoppingViewModel>();

    if (isOrderedByName) {
      shoppingViewModel.listInventoryItems.sort((a, b) {
        Item itemA =
            context.read<ShoppingViewModel>().itemRepo.getItemById(a.itemId)!;
        Item itemB =
            context.read<ShoppingViewModel>().itemRepo.getItemById(b.itemId)!;
        return removeDiacritics(itemA.name).compareTo(
          removeDiacritics(itemB.name),
        );
      });
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems =
            shoppingViewModel.listInventoryItems.reversed.toList();
      }
    }

    if (isOrderedByPrice) {
      shoppingViewModel.listInventoryItems.sort((a, b) {
        Item itemA =
            context.read<ShoppingViewModel>().itemRepo.getItemById(a.itemId)!;
        Item itemB =
            context.read<ShoppingViewModel>().itemRepo.getItemById(b.itemId)!;
        return itemA.price.compareTo(itemB.price);
      });
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems =
            shoppingViewModel.listInventoryItems.reversed.toList();
      }
    }

    if (isOrderedByWeight) {
      shoppingViewModel.listInventoryItems.sort((a, b) {
        Item itemA =
            context.read<ShoppingViewModel>().itemRepo.getItemById(a.itemId)!;
        Item itemB =
            context.read<ShoppingViewModel>().itemRepo.getItemById(b.itemId)!;
        return itemA.weight.compareTo(itemB.weight);
      });
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems =
            shoppingViewModel.listInventoryItems.reversed.toList();
      }
    }

    if (isOrderedByAmount) {
      shoppingViewModel.listInventoryItems
          .sort((a, b) => a.amount.compareTo(b.amount));
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems =
            shoppingViewModel.listInventoryItems.reversed.toList();
      }
    }
    setState(() {});
  }
}
