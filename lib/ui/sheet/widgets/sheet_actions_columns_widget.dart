import 'package:flutter/material.dart';
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
      child: SizedBox(
        width: width(context),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          runAlignment: WrapAlignment.center,
          runSpacing: 32,
          children: [
            ListActionsWidget(
              name: "Ações Básicas",
              isEditing: viewModel.isEditing,
              listActions:
                  context.read<SheetViewModel>().actionRepo.getBasics(),
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
