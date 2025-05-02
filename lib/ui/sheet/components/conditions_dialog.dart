import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../view/sheet_view_model.dart';
import '../widgets/condition_widget.dart';

Future<dynamic> showSheetConditionsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(child: SheetConditionsScreen());
    },
  );
}

class SheetConditionsScreen extends StatelessWidget {
  const SheetConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(400, width(context)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Estados"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              context.read<SheetViewModel>().conditionRepo.getConditions.length,
              (index) {
                return ConditionWidget(
                    condition: context
                        .read<SheetViewModel>()
                        .conditionRepo
                        .getConditions[index]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
