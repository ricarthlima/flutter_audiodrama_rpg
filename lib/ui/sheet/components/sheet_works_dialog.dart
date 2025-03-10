import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/wip_snackbar.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/open_popup.dart';
import 'package:flutter_rpg_audiodrama/ui/settings/view/settings_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/widgets/list_actions_widget.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Ofícios"),
        actions: [
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
          if (!widget.isPopup)
            Row(
              mainAxisSize: MainAxisSize.min,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("•"),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Popup ta bugado apagando tudo
                    // Navigator.pop(context);
                    // openPopup("sheet/${sheetViewModel.id}/works");
                    showSnackBarWip(context);
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
            children: (!settingsProvider.showingOnlyMyWorks)
                ? List.generate(
                    ActionDAO.instance.mapWorks.keys.length,
                    (index) {
                      String key =
                          ActionDAO.instance.mapWorks.keys.toList()[index];
                      return ListActionsWidget(
                        name: key,
                        listActions: ActionDAO.instance.getListWorksByKey(key),
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
                        listActions: ActionDAO.instance.getListWorksByKey(key),
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
