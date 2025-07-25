import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view/sheet_view_model.dart';
import 'sheet_history_drawer.dart';

Drawer getSheetDrawer(BuildContext context) {
  final viewModel = Provider.of<SheetViewModel>(context);
  return Drawer(
    child: SheetHistoryDrawer(listRollLog: viewModel.sheet!.listRollLog),
  );
}
