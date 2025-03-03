import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/condition.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:provider/provider.dart';

class ConditionWidget extends StatelessWidget {
  final Condition condition;
  const ConditionWidget({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    return ListTile(
      leading: Checkbox(
        value: sheetViewModel.getHasCondition(condition.id),
        onChanged: (value) {
          sheetViewModel.toggleCondition(condition.id);
        },
      ),
      title: Text(condition.name),
      subtitle: Text(condition.description),
    );
  }
}
