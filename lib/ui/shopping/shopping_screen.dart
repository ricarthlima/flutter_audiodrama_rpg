import 'package:flutter/material.dart';
import 'view/shopping_view_model.dart';
import 'package:provider/provider.dart';

import '../_core/dimensions.dart';
import '../sheet/view/sheet_view_model.dart';
import 'widgets/shopping_list_widget.dart';

class ShoppingDialogScreen extends StatefulWidget {
  const ShoppingDialogScreen({super.key});

  @override
  State<ShoppingDialogScreen> createState() => _ShoppingDialogScreenState();
}

class _ShoppingDialogScreenState extends State<ShoppingDialogScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shoppingVM = Provider.of<ShoppingViewModel>(
        context,
        listen: false,
      );
      shoppingVM.openInventory(
        context.read<SheetViewModel>().sheet!.listItemSheet,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingVM = Provider.of<ShoppingViewModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        (shoppingVM.isBuying)
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
                          ShoppingListWidget(
                            isSeller: false,
                          ),
                          ShoppingListWidget(
                            isSeller: true,
                          ),
                        ],
                      ),
                    ),
                  )
            : ShoppingListWidget(isSeller: false),
      ],
    );
  }
}
