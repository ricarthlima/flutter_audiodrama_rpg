import 'package:flutter/material.dart';

import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../../domain/models/action_template.dart';
import 'action_widget.dart';

class ListActionsWidget extends StatelessWidget {
  final String name;
  final List<ActionTemplate> listActions;
  final bool isEditing;

  const ListActionsWidget({
    super.key,
    required this.name,
    required this.listActions,
    required this.isEditing,
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
              fontFamily: FontFamily.bungee,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
