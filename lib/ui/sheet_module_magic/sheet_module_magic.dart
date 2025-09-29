import 'package:flutter/material.dart';
import '../sheet/providers/sheet_view_model.dart';
import 'widgets/list_spells_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../domain/dto/spell.dart';

class SheetModuleMagic extends StatelessWidget {
  const SheetModuleMagic({super.key});

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Flexible(
          child: DragTarget<Spell>(
            onAcceptWithDetails: (details) {
              sheetVM.addSpell(details.data);
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _listSheetSpells(sheetVM).isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 16,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.wandMagicSparkles,
                                  size: 24,
                                ),
                                Text(
                                  "Nenhum feitiço ainda, edite a ficha e arraste o ícone para essa área para adicionar.",
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListSpellsWidget(
                          listSpells: _listSheetSpells(sheetVM),
                          title: "Meus feitiços",
                        ),
                  if (candidateData.isNotEmpty)
                    Positioned.fill(
                      child: Container(color: Colors.white.withAlpha(100)),
                    ),
                ],
              );
            },
          ),
        ),
        if (sheetVM.isEditing) VerticalDivider(),
        if (sheetVM.isEditing)
          Flexible(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ListSpellsWidget(
                  title: "Todos os feitiços",
                  listSpells: sheetVM.spellRepo.getAll(),
                  isDense: false,
                  isDraggable: true,
                  isMine: false,
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Spell> _listSheetSpells(SheetViewModel sheetVM) {
    List<Spell> listSpell = [];

    for (String spellId in sheetVM.sheet!.listSpell) {
      for (Spell spell in sheetVM.spellRepo.getAll()) {
        if (spell.id == spellId) {
          listSpell.add(spell);
        }
      }
    }

    return listSpell;
  }
}
