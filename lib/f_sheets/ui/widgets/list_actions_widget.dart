import 'package:flutter/material.dart';

import '../../../_core/dimensions.dart';
import '../../../_core/fonts.dart';
import '../../models/action_template.dart';
import '../../models/sheet_model.dart';
import 'action_widget.dart';

class ListActionsWidget extends StatelessWidget {
  final String name;
  final List<ActionTemplate> listActions;
  final Sheet sheet;
  final bool isEditing;
  final Function(ActionValue ac) onActionValueChanged;
  final Function(RollLog roll) onRoll;
  final int? modRoll;

  const ListActionsWidget({
    super.key,
    required this.name,
    required this.listActions,
    required this.sheet,
    required this.isEditing,
    required this.onActionValueChanged,
    required this.onRoll,
    this.modRoll,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: (isVertical(context))
              ? width(context)
              : getZoomFactor(
                  context,
                  330,
                ),
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: Theme.of(context).textTheme.bodyMedium!.color!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 16,
            right: 16,
            left: 16,
          ),
          margin: EdgeInsets.only(top: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                listActions.length,
                (index) {
                  ActionTemplate action = listActions[index];
                  return ActionWidget(
                    action: action,
                    isEditing: isEditing,
                    sheet: sheet,
                    onActionValueChanged: onActionValueChanged,
                    onRoll: onRoll,
                    modRoll: modRoll,
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            name,
            style: TextStyle(
              fontSize: isVertical(context) ? 20 : getZoomFactor(context, 22),
              fontFamily: FontFamilies.bungee,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
