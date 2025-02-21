import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../../_core/theme_provider.dart';
import '../view/sheet_view_model.dart';

FloatingActionButton? getSheetFloatingActionButton(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final viewModel = Provider.of<SheetViewModel>(context);

  return isVertical(context)
      ? FloatingActionButton(
          onPressed: () => viewModel.onItemsButtonClicked(context),
          child: Image.asset(
            (themeProvider.themeMode == ThemeMode.dark)
                ? "assets/images/chest.png"
                : "assets/images/chest-i.png",
            width: 32,
          ),
        )
      : null;
}
