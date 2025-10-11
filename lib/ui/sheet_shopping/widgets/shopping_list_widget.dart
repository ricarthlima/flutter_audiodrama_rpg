import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/app_colors.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../_core/helpers.dart';
import '../../sheet/providers/sheet_view_model.dart';
import '../view/shopping_view_model.dart';
import 'item_category_widget.dart';
import 'shopping_item_widget.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
      _orderItems();
      _orderItemsMine();
    });
  }

  Row _buildToggleStore(
    ShoppingViewModel shoppingVM,
    SheetViewModel sheetVM,
    BuildContext context,
  ) {
    return Row(
      spacing: 16,
      children: [
        if (!shoppingVM.isBuying)
          Text(
            "\$ ${sheetVM.sheet!.money}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                fontSize: 20,
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
            child: Text(shoppingVM.isBuying ? "Fechar loja" : "Abrir loja"),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);
    final shoppingVM = Provider.of<ShoppingViewModel>(context);

    return Expanded(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              SizedBox(
                height: 42,
                child: Row(
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
                              IntrinsicWidth(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: CheckboxListTile(
                                    value: shoppingVM.isFree,
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: Text("De graça"),
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (value) {
                                      shoppingVM.isFree = !shoppingVM.isFree;
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!widget.isSeller)
                      _buildToggleStore(shoppingVM, sheetVM, context),
                  ],
                ),
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
              if (widget.isSeller)
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
                              : shoppingVM.listFilteredCategoriesSeller
                                    .contains(e),
                        );
                      })
                      .toList(),
                ),
              SizedBox(
                height: 450 * (height(context) / 866),
                child: DragTarget<Item>(
                  onAcceptWithDetails: (details) {
                    if (!widget.isSeller) {
                      shoppingVM.buyItem(item: details.data);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Stack(
                      children: [
                        GridView.builder(
                          shrinkWrap: false,
                          padding: EdgeInsets.only(right: 16),
                          physics: AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 128,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: (widget.isSeller)
                              ? shoppingVM.listSellerItems.length
                              : shoppingVM.listInventoryItems.length,
                          itemBuilder: (context, index) {
                            Item? item;
                            ItemSheet? itemSheet;

                            if (widget.isSeller) {
                              item = shoppingVM.listSellerItems[index];
                            } else {
                              itemSheet = shoppingVM.listInventoryItems[index];
                              item = shoppingVM.itemRepo.getItemById(
                                itemSheet.itemId,
                                listCustomItem: sheetVM.sheet!.listCustomItems,
                              )!;
                            }

                            return ShoppingItemWidget(
                              item: item,
                              itemSheet: itemSheet,
                            );
                          },
                        ),
                        if (candidateData.isNotEmpty && !widget.isSeller)
                          Container(
                            alignment: Alignment.center,
                            color: Colors.white.withAlpha(30),
                            child: Text("Comprar"),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (!shoppingVM.isBuying)
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  sheetVM.showItemDialog();
                },
                child: Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadItems() async {
    final shoppingViewModel = context.read<ShoppingViewModel>();
    shoppingViewModel.onSearchOnInventory();
    shoppingViewModel.onSearchOnSeller();
    _orderItems();
    _orderItemsMine();
  }

  void _orderItems() {
    final shoppingViewModel = context.read<ShoppingViewModel>();

    if (isOrderedByName) {
      shoppingViewModel.listSellerItems.sort(
        (a, b) => removeDiacritics(a.name).compareTo(removeDiacritics(b.name)),
      );
      if (!isAscendent) {
        shoppingViewModel.listSellerItems = shoppingViewModel
            .listSellerItems
            .reversed
            .toList();
      }
    }

    if (isOrderedByPrice) {
      shoppingViewModel.listSellerItems.sort(
        (a, b) => a.price.compareTo(b.price),
      );
      if (!isAscendent) {
        shoppingViewModel.listSellerItems = shoppingViewModel
            .listSellerItems
            .reversed
            .toList();
      }
    }

    if (isOrderedByWeight) {
      shoppingViewModel.listSellerItems.sort(
        (a, b) => a.weight.compareTo(b.weight),
      );
      if (!isAscendent) {
        shoppingViewModel.listSellerItems = shoppingViewModel
            .listSellerItems
            .reversed
            .toList();
      }
    }

    setState(() {});
  }

  void _orderItemsMine() {
    final shoppingViewModel = context.read<ShoppingViewModel>();
    final sheetVM = context.read<SheetViewModel>();

    if (isOrderedByName) {
      shoppingViewModel.listInventoryItems.sort((a, b) {
        Item itemA = context.read<ShoppingViewModel>().itemRepo.getItemById(
          a.itemId,
          listCustomItem: sheetVM.sheet!.listCustomItems,
        )!;
        Item itemB = context.read<ShoppingViewModel>().itemRepo.getItemById(
          b.itemId,
          listCustomItem: sheetVM.sheet!.listCustomItems,
        )!;
        return removeDiacritics(
          itemA.name,
        ).compareTo(removeDiacritics(itemB.name));
      });
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems = shoppingViewModel
            .listInventoryItems
            .reversed
            .toList();
      }
    }

    if (isOrderedByPrice) {
      shoppingViewModel.listInventoryItems.sort((a, b) {
        Item itemA = context.read<ShoppingViewModel>().itemRepo.getItemById(
          a.itemId,
          listCustomItem: sheetVM.sheet!.listCustomItems,
        )!;
        Item itemB = context.read<ShoppingViewModel>().itemRepo.getItemById(
          b.itemId,
          listCustomItem: sheetVM.sheet!.listCustomItems,
        )!;
        return itemA.price.compareTo(itemB.price);
      });
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems = shoppingViewModel
            .listInventoryItems
            .reversed
            .toList();
      }
    }

    if (isOrderedByWeight) {
      shoppingViewModel.listInventoryItems.sort((a, b) {
        Item itemA = context.read<ShoppingViewModel>().itemRepo.getItemById(
          a.itemId,
          listCustomItem: sheetVM.sheet!.listCustomItems,
        )!;
        Item itemB = context.read<ShoppingViewModel>().itemRepo.getItemById(
          b.itemId,
          listCustomItem: sheetVM.sheet!.listCustomItems,
        )!;
        return itemA.weight.compareTo(itemB.weight);
      });
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems = shoppingViewModel
            .listInventoryItems
            .reversed
            .toList();
      }
    }

    if (isOrderedByAmount) {
      shoppingViewModel.listInventoryItems.sort(
        (a, b) => a.amount.compareTo(b.amount),
      );
      if (!isAscendent) {
        shoppingViewModel.listInventoryItems = shoppingViewModel
            .listInventoryItems
            .reversed
            .toList();
      }
    }
    setState(() {});
  }
}
