import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../../../domain/models/action_template.dart';
import '../view/sheet_view_model.dart';
import 'action_widget.dart';

class ListActionsWidget extends StatelessWidget {
  final String name;
  final List<ActionTemplate> listActions;
  final bool isEditing;
  final bool isWork;

  const ListActionsWidget({
    super.key,
    required this.name,
    required this.listActions,
    required this.isEditing,
    this.isWork = false,
  });

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);
    return Container(
      width: (isVertical(context))
          ? width(context)
          : getZoomFactor(
              context,
              sheetVM.isWindowed ? 290 : 350,
            ),
      // height: height,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: isVertical(context) ? 16 : getZoomFactor(context, 18),
              fontFamily: FontFamily.bungee,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }
}
