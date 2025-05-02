import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_lore.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/action_template.dart';

showActionLoreDialog(
  BuildContext context,
  ActionTemplate action,
) {
  showDialog(
    context: context,
    builder: (context) {
      return _ActionLoreDialog(action: action);
    },
  );
}

class _ActionLoreDialog extends StatefulWidget {
  final ActionTemplate action;
  const _ActionLoreDialog({required this.action});

  @override
  State<_ActionLoreDialog> createState() => _ActionLoreDialogState();
}

class _ActionLoreDialogState extends State<_ActionLoreDialog> {
  final TextEditingController _loreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sheetViewModel = context.read<SheetViewModel>();
    _loreController.text = sheetViewModel.sheet!.listActionLore
        .firstWhere(
          (e) => e.actionId == widget.action.id,
          orElse: () => ActionLore(actionId: widget.action.id, loreText: ""),
        )
        .loreText;
  }

  @override
  Widget build(BuildContext context) {
    final sheetViewModel = Provider.of<SheetViewModel>(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: min(600, width(context)),
        decoration: BoxDecoration(
          border: Border.all(
            width: 4,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text(
              "Você possui ${sheetViewModel.getTrainLevelByActionName(widget.action.id)} em '${widget.action.name}'.\nPor quê?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontFamily.bungee,
                fontSize: 18,
              ),
            ),
            TextFormField(
              controller: _loreController,
              maxLines: 10,
            ),
            ElevatedButton(
              onPressed: () {
                sheetViewModel.saveActionLore(
                  actionId: widget.action.id,
                  loreText: _loreController.text,
                );
                Navigator.pop(context);
              },
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
