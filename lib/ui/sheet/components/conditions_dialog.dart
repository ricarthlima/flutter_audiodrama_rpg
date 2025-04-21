import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/condition_dao.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/condition_widget.dart';

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
              ConditionDAO.instance.getConditions.length,
              (index) {
                return ConditionWidget(
                    condition: ConditionDAO.instance.getConditions[index]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
