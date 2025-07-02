import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
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
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ListActionsWidget(
                        name: "Ações Básicas",
                        isEditing: sheetVM.isEditing,
                        listActions: context
                            .read<SheetViewModel>()
                            .actionRepo
                            .getBasics(),
                      ),
                    ),
                    ListActionsWidget(
                      name: "Ações Resistidas",
                      isEditing: sheetVM.isEditing,
                      color: AppColors.red,
                      listActions: context
                          .read<SheetViewModel>()
                          .actionRepo
                          .getResisted(),
                    ),
                  ],
                ),
                ListActionsWidget(
                  name: "Ações de Força",
                  isEditing: sheetVM.isEditing,
                  listActions:
                      context.read<SheetViewModel>().actionRepo.getStrength(),
                ),
                ListActionsWidget(
                  name: "Ações de Agilidade",
                  isEditing: sheetVM.isEditing,
                  listActions:
                      context.read<SheetViewModel>().actionRepo.getAgility(),
                ),
                ListActionsWidget(
                  name: "Ações de Intelecto",
                  isEditing: sheetVM.isEditing,
                  listActions:
                      context.read<SheetViewModel>().actionRepo.getIntellect(),
                ),
                ListActionsWidget(
                  name: "Ações Sociais",
                  isEditing: sheetVM.isEditing,
                  listActions:
                      context.read<SheetViewModel>().actionRepo.getSocial(),
                ),
              ] +
              List.generate(
                sheetVM.sheet!.listActiveWorks.length,
                (index) {
                  String key = sheetVM.sheet!.listActiveWorks[index];
                  return ListActionsWidget(
                    name: "(Ofício) $key",
                    color: Colors.amber,
                    listActions: context
                        .read<SheetViewModel>()
                        .actionRepo
                        .getActionsByGroupName(key),
                    isEditing: sheetVM.isEditing,
                    isWork: true,
                  );
                },
              ),
        ),
      ),
    );
  }
}
