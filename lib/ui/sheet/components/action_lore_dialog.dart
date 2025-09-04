import 'dart:math';

import 'package:flutter/material.dart';
import '../../../domain/models/action_lore.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../providers/sheet_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/action_template.dart';

class ActionLoreStackDialog extends StatefulWidget {
  final ActionTemplate action;
  const ActionLoreStackDialog({super.key, required this.action});

  @override
  State<ActionLoreStackDialog> createState() => _ActionLoreStackDialogState();
}

class _ActionLoreStackDialogState extends State<ActionLoreStackDialog> {
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
          border: Border.all(width: 4, color: Colors.white),
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
              style: TextStyle(fontFamily: FontFamily.bungee, fontSize: 18),
            ),
            TextFormField(controller: _loreController, maxLines: 10),
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
