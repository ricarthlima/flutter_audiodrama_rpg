import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/utils/i18n_categories.dart';
import '../../sheet/providers/sheet_view_model.dart';
import '../view/shopping_interact.dart';
import '../view/shopping_view_model.dart';

class ItemTooltip extends StatelessWidget {
  final Item item;
  final ItemSheet? itemSheet;
  final Function onEnter;
  final Function onExit;

  const ItemTooltip({
    super.key,
    required this.item,
    required this.onEnter,
    required this.onExit,
    this.itemSheet,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingVM = Provider.of<ShoppingViewModel>(context);
    final sheetVM = context.read<SheetViewModel>();

    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                (itemSheet != null)
                    ? "${item.name} (x${itemSheet!.amount})"
                    : item.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: item.listCategories
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text(
                              i18nCategories(e),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 8),
                  Text(item.description),
                  Text(
                    item.mechanic,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Visibility(
                    visible: item.isFinite,
                    child: Text("Máximo de usos: ${item.maxUses}"),
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        if (item.isFinite && itemSheet != null)
                          Row(
                            spacing: 8,
                            children: [
                              Tooltip(
                                message: "Usos restantes",
                                child: Icon(Icons.numbers),
                              ),
                              Text(
                                _getTotalAmount(
                                  shoppingVM.listInventoryItems
                                      .firstWhere((e) => e.itemId == item.id)
                                      .uses,
                                ),
                                style: TextStyle(fontSize: 16),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text("•"),
                              ),
                            ],
                          ),
                        Tooltip(
                          message: "Preço",
                          child: Icon(Icons.attach_money_sharp),
                        ),
                        Text(
                          item.price.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("•"),
                        ),
                        Tooltip(
                          message: "Peso",
                          child: Icon(Icons.fitness_center),
                        ),
                        Text(
                          item.weight.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!shoppingVM.isBuying)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.isFinite)
                        TextButton(
                          onPressed: () => shoppingVM.useItem(
                            itemId: item.id,
                            listCustomItem: sheetVM.sheet!.listCustomItems,
                          ),
                          child: Text("Usar"),
                        ),
                      if (item.isFinite)
                        TextButton(
                          onPressed: () =>
                              shoppingVM.reloadUses(itemId: item.id),
                          child: Text("Recarregar usos"),
                        ),
                      TextButton(
                        onPressed: () => ShoppingInteract.removeItem(
                          context: context,
                          itemId: item.id,
                          shoppingVM: shoppingVM,
                        ),
                        child: Text("Remover"),
                      ),
                      TextButton(
                        onPressed: () => ShoppingInteract.removeAllFromItem(
                          context: context,
                          itemId: item.id,
                          shoppingVM: shoppingVM,
                        ),
                        child: Text("Remover tudo"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTotalAmount(int currentAmount) {
    return "${(item.maxUses ?? 0) - currentAmount} usos restantes";
  }
}


              // trailing: (shoppingVM.isBuying)
              //     ? IconButton(
              //         onPressed: () => shoppingVM.sellItem(itemId: item.id),
              //         tooltip: "Vender",
              //         color: AppColors.red,
              //         iconSize: 48,
              //         icon: Icon(Icons.keyboard_arrow_right),
              //       )
              //     : null,