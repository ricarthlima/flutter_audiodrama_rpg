import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view/home_view_model.dart';

FloatingActionButton getHomeFAB(BuildContext context) {
  final viewModel = Provider.of<HomeViewModel>(context);

  return FloatingActionButton(
    onPressed: () {
      viewModel.onCreateSheetClicked(context);
    },
    child: Icon(Icons.add),
  );
}
