import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_template.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/action_lore_dialog.dart';
import 'package:provider/provider.dart';

import '../../sheet/view/sheet_view_model.dart';

class BioWidget extends StatelessWidget {
  const BioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Flexible(
            flex: (isVertical(context)) ? 9 : 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 32,
              children: [
                Text(
                  "Quais segredos estão guardados no seu passado?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sheetViewModel.isOwner)
                  Expanded(
                    child: TextFormField(
                      controller: sheetViewModel.bioEditingController(),
                      maxLines: null,
                      expands: true,
                      enabled: sheetViewModel.isOwner,
                    ),
                  ),
                if (!sheetViewModel.isOwner)
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        sheetViewModel.bioEditingController().text,
                      ),
                    ),
                  ),
                if (sheetViewModel.isOwner)
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 750),
                    child: (sheetViewModel.isSavingBio == null)
                        ? ElevatedButton(
                            onPressed: () {
                              sheetViewModel.saveBio();
                            },
                            child: Text("Salvar"),
                          )
                        : (sheetViewModel.isSavingBio!)
                            ? Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Icon(
                                Icons.check,
                                size: 32,
                              ),
                  ),
              ],
            ),
          ),
          VerticalDivider(),
          Flexible(
            flex: (!isVertical(context)) ? 3 : 6,
            child: SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.arrow_back_ios_new_outlined),
                          title: Text("Transferir para o texto"),
                          onTap: () {
                            sheetViewModel.addTextToEndActionValues();
                          },
                        ),
                        Divider(),
                      ] +
                      sheetViewModel.getActionsValuesWithWorks().map(
                        (e) {
                          return _ActionLoreWidget(
                            action:
                                ActionDAO.instance.getActionById(e.actionId)!,
                          );
                        },
                      ).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionLoreWidget extends StatelessWidget {
  final ActionTemplate action;
  const _ActionLoreWidget({required this.action});

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);
    return ListTile(
      onTap: () => showActionLoreDialog(context, action),
      title: Text(
        "(${sheetViewModel.getTrainLevelByActionName(action.id)}) ${action.name}",
        style: TextStyle(
          color: (!sheetViewModel.sheet!.listActionLore
                  .where((e) => e.actionId == action.id)
                  .isNotEmpty)
              ? AppColors.red
              : null,
          fontFamily: FontFamily.bungee,
        ),
      ),
      subtitle: (sheetViewModel.sheet!.listActionLore
              .where((e) => e.actionId == action.id)
              .isNotEmpty)
          ? SelectableText(sheetViewModel.sheet!.listActionLore
              .firstWhere((e) => e.actionId == action.id)
              .loreText)
          : null,
    );
  }
}
