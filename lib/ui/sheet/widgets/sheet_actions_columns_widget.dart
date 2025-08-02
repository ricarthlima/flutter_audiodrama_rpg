import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/models/group_action.dart';
import '../../_core/app_colors.dart';
import 'package:provider/provider.dart';

import '../view/sheet_view_model.dart';
import 'list_actions_widget.dart';

class SheetActionsColumnsWidget extends StatelessWidget {
  final ScrollController? scrollController;
  const SheetActionsColumnsWidget({
    super.key,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      Expanded(
                        child: ListActionsWidget(
                          name: "Básicas",
                          isEditing: sheetVM.isEditing,
                          groupAction:
                              sheetVM.mapGroupAction[GroupActionIds.basic]!,
                        ),
                      ),
                      ListActionsWidget(
                        name: "Resistidas",
                        isEditing: sheetVM.isEditing,
                        color: AppColors.red,
                        groupAction:
                            sheetVM.mapGroupAction[GroupActionIds.resisted]!,
                      ),
                    ],
                  ),
                  ListActionsWidget(
                    name: "Força",
                    isEditing: sheetVM.isEditing,
                    groupAction:
                        sheetVM.mapGroupAction[GroupActionIds.strength]!,
                  ),
                  ListActionsWidget(
                    name: "Agilidade",
                    isEditing: sheetVM.isEditing,
                    groupAction:
                        sheetVM.mapGroupAction[GroupActionIds.agility]!,
                  ),
                  ListActionsWidget(
                    name: "Intelecto",
                    isEditing: sheetVM.isEditing,
                    groupAction:
                        sheetVM.mapGroupAction[GroupActionIds.intellect]!,
                  ),
                  ListActionsWidget(
                    name: "Sociais",
                    isEditing: sheetVM.isEditing,
                    groupAction: sheetVM.mapGroupAction[GroupActionIds.social]!,
                  ),
                ] +
                List.generate(
                  sheetVM.sheet!.listActiveWorks.length,
                  (index) {
                    String key = sheetVM.sheet!.listActiveWorks[index];
                    return ListActionsWidget(
                      name: key,
                      color: Colors.amber,
                      groupAction: sheetVM.mapGroupAction[key]!,
                      isEditing: sheetVM.isEditing,
                    );
                  },
                ),
          ),
        ),
      ),
    );
  }
}
