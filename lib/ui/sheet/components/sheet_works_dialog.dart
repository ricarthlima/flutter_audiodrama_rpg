import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/open_popup.dart';
import 'package:flutter_rpg_audiodrama/ui/settings/view/settings_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/list_actions_widget.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/list_action.dart';
import '../../_core/widgets/loading_widget.dart';
import '../widgets/sheet_not_found_widget.dart';

Future<dynamic> showSheetWorksDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SheetWorksDialog(),
      );
    },
  );
}

class SheetWorksDialog extends StatefulWidget {
  final bool isPopup;
  const SheetWorksDialog({super.key, this.isPopup = false});

  @override
  State<SheetWorksDialog> createState() => _SheetWorksDialogState();
}

class _SheetWorksDialogState extends State<SheetWorksDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.isPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<SheetViewModel>(context, listen: false);
        viewModel.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    return (sheetViewModel.isLoading)
        ? LoadingWidget()
        : (sheetViewModel.isFoundSheet)
            ? _buildBody(context)
            : SheetNotFoundWidget();
  }

  Scaffold _buildBody(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text((widget.isPopup) ? "Meus Ofícios" : "Ofícios"),
        actions: [
          if (!widget.isPopup)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Checkbox(
                      value: settingsProvider.showingOnlyMyWorks,
                      onChanged: (value) {
                        if (value != null) {
                          settingsProvider.showingOnlyMyWorks = value;
                        }
                      },
                    ),
                    Text("Mostrar só meus ofícios")
                  ],
                ),
                if (sheetViewModel.isOwner)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("•"),
                      ),
                      Visibility(
                        visible: sheetViewModel.isEditing,
                        child: Text("Saia da edição para salvar"),
                      ),
                      Visibility(
                        visible: sheetViewModel.isEditing,
                        child: SizedBox(width: 8),
                      ),
                      Icon(Icons.edit),
                      Switch(
                        value: sheetViewModel.isEditing,
                        onChanged: (value) {
                          sheetViewModel.toggleEditMode();
                        },
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("•"),
                ),
                IconButton(
                  onPressed: () {
                    openPopup(
                        "${sheetViewModel.username}/sheet/${sheetViewModel.id}/works");
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.outbond_outlined),
                ),
              ],
            ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 32,
            runSpacing: 32,
            children: (!settingsProvider.showingOnlyMyWorks && !widget.isPopup)
                ? List.generate(
                    ActionDAO.instance.getListWorks().length,
                    (index) {
                      ListAction currentListWork =
                          ActionDAO.instance.getListWorks()[index];
                      return ListActionsWidget(
                        name: currentListWork.name,
                        listActions: currentListWork.listActions,
                        isEditing: sheetViewModel.isEditing,
                        isWork: true,
                      );
                    },
                  )
                : List.generate(
                    sheetViewModel.getWorkIds().length,
                    (index) {
                      String key = sheetViewModel.getWorkIds()[index];
                      return ListActionsWidget(
                        name: key,
                        listActions:
                            ActionDAO.instance.getActionsByGroupName(key),
                        isEditing: sheetViewModel.isEditing,
                        isWork: true,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
