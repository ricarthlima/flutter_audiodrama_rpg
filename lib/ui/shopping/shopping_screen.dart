import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/shopping/view/shopping_view_model.dart';
import 'package:provider/provider.dart';

import '../_core/dimensions.dart';
import '../sheet/view/sheet_view_model.dart';
import 'widgets/shopping_list_widget.dart';

Future<dynamic> showShoppingDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        child: ShoppingDialogScreen(),
      );
    },
  );
}

class ShoppingDialogScreen extends StatefulWidget {
  const ShoppingDialogScreen({super.key});

  @override
  State<ShoppingDialogScreen> createState() => _ShoppingDialogScreenState();
}

class _ShoppingDialogScreenState extends State<ShoppingDialogScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SheetViewModel>(context);
    final shoppingViewModel = Provider.of<ShoppingViewModel>(context);

    return Scaffold(
      floatingActionButton: (isVertical(context))
          ? FloatingActionButton(
              onPressed: () {
                shoppingViewModel.toggleBuying();
              },
              child: Text("Loja"),
            )
          : null,
      body: Container(
        height: height(context),
        width: width(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: !isVertical(context),
                  child: Text(
                    "Inventário",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontFamily.bungee,
                      color: AppColors.red,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    if (!shoppingViewModel.isBuying)
                      Text(
                        "\$ ${viewModel.money}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (shoppingViewModel.isBuying)
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller:
                              shoppingViewModel.getMoneyTextController(context),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.attach_money_rounded,
                              color: shoppingViewModel.showingHaveNoMoney
                                  ? AppColors.red
                                  : null,
                            ),
                            suffix: InkWell(
                              onTap: (shoppingViewModel
                                          .isShowingMoneyFeedback ==
                                      null)
                                  ? () {
                                      shoppingViewModel.onEditingMoney(context);
                                    }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  (shoppingViewModel.isShowingMoneyFeedback ==
                                          null)
                                      ? Icons.save
                                      : (shoppingViewModel
                                              .isShowingMoneyFeedback!)
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
                            color: shoppingViewModel.showingHaveNoMoney
                                ? AppColors.red
                                : null,
                          ),
                        ),
                      ),
                    if (!isVertical(context)) SizedBox(width: 16),
                    if (!isVertical(context))
                      SizedBox(
                        width: 150,
                        child: SwitchListTile(
                          title: Text("Loja"),
                          value: shoppingViewModel.isBuying,
                          onChanged: (_) {
                            shoppingViewModel.toggleBuying();
                          },
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 32,
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(),
            ),
            (shoppingViewModel.isBuying)
                ? !isVertical(context)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Flexible(
                            flex: 5,
                            child: ShoppingListWidget(isSeller: false),
                          ),
                          Flexible(
                            flex: 5,
                            child: ShoppingListWidget(isSeller: true),
                          ),
                        ],
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 32,
                            children: [
                              ShoppingListWidget(isSeller: false),
                              ShoppingListWidget(isSeller: true),
                            ],
                          ),
                        ),
                      )
                : ShoppingListWidget(isSeller: false),
          ],
        ),
      ),
    );
  }
}
