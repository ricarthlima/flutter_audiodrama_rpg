import 'package:flutter/material.dart';

import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../../domain/models/action_template.dart';
import 'action_widget.dart';

class ListActionsWidget extends StatelessWidget {
  final String name;
  final List<ActionTemplate> listActions;
  final bool isEditing;
  final bool isWork;
  final Color? color;

  const ListActionsWidget({
    super.key,
    required this.name,
    required this.listActions,
    required this.isEditing,
    this.isWork = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          (isVertical(context)) ? width(context) : (width(context) / 5) - (40),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: (color != null)
              ? color!
              : Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: isVertical(context) ? 16 : getZoomFactor(context, 18),
              fontFamily: FontFamily.bungee,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                // TODO: Ações ativadas por padrão config de campanha
                listActions.where((e) => e.enabled).length,
                (index) {
                  ActionTemplate action =
                      listActions.where((e) => e.enabled).toList()[index];
                  return ActionWidget(
                    action: action,
                    isWork: isWork,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
