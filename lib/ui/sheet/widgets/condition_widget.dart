import 'package:flutter/material.dart';
import '../../../domain/models/condition.dart';
import '../view/sheet_view_model.dart';
import 'package:provider/provider.dart';

class ConditionWidget extends StatelessWidget {
  final Condition condition;
  const ConditionWidget({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final sheetViewModel = Provider.of<SheetViewModel>(context);
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
