import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/widgets/generic_header.dart';
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
                      : Expanded(
                          child: ListView(
                            children:
                                <Widget>[
                                  GenericHeader(title: "Meus feitiços"),
                                ] +
                                getListsByEnergy(sheetVM),
                          ),
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

  List<Widget> getListsByEnergy(SheetViewModel sheetVM) {
    Map<int, List<Spell>> map = _mapEnergySpell(_listSheetSpells(sheetVM));

    List<Widget> result = [];

    for (int i = -50; i < 50; i++) {
      if (map[i] != null) {
        map[i]!.sort((a, b) => a.name.compareTo(b.name));
        result.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ListSpellsWidget(
              title: "Energia $i",
              listSpells: map[i]!,
              isDense: true,
              hideSearch: true,
              showExpand: true,
            ),
          ),
        );
      }
    }

    return result;
  }

  Map<int, List<Spell>> _mapEnergySpell(List<Spell> listSpell) {
    Map<int, List<Spell>> result = {};

    for (Spell spell in listSpell) {
      int energy = int.parse(spell.energy.replaceAll("+", ""));
      if (result[energy] == null) {
        result[energy] = [spell];
      } else {
        result[energy]!.add(spell);
      }
    }

    return result;
  }
}
