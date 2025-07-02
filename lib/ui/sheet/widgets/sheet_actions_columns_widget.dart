import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:provider/provider.dart';

import '../../_core/dimensions.dart';
import '../view/sheet_view_model.dart';
import 'list_actions_widget.dart';

class SheetActionsColumnsWidget extends StatelessWidget {
  const SheetActionsColumnsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SheetViewModel>(context);
    return SingleChildScrollView(
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
                    isEditing: viewModel.isEditing,
                    listActions:
                        context.read<SheetViewModel>().actionRepo.getBasics(),
                  ),
                ),
                ListActionsWidget(
                  name: "Ações Resistidas",
                  isEditing: viewModel.isEditing,
                  color: AppColors.red,
                  listActions:
                      context.read<SheetViewModel>().actionRepo.getResisted(),
                ),
              ],
            ),
            ListActionsWidget(
              name: "Ações de Força",
              isEditing: viewModel.isEditing,
              listActions:
                  context.read<SheetViewModel>().actionRepo.getStrength(),
            ),
            ListActionsWidget(
              name: "Ações de Agilidade",
              isEditing: viewModel.isEditing,
              listActions:
                  context.read<SheetViewModel>().actionRepo.getAgility(),
            ),
            ListActionsWidget(
              name: "Ações de Intelecto",
              isEditing: viewModel.isEditing,
              listActions:
                  context.read<SheetViewModel>().actionRepo.getIntellect(),
            ),
            ListActionsWidget(
              name: "Ações Sociais",
              isEditing: viewModel.isEditing,
              listActions:
                  context.read<SheetViewModel>().actionRepo.getSocial(),
            ),
          ],
        ),
      ),
    );
  }
}
