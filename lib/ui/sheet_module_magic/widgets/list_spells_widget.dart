import 'package:flutter/material.dart';
import '../../../_core/providers/user_provider.dart';
import '../../../data/modules.dart';
import '../../../domain/dto/action_template.dart';
import '../../../domain/dto/spell.dart';
import '../../../domain/models/campaign.dart';
import '../../../domain/models/sheet_custom_count.dart';
import '../../_core/constants/roll_type.dart';
import '../../_core/widgets/generic_filter_widget.dart';
import '../../_core/widgets/generic_header.dart';
import '../../sheet/providers/sheet_interact.dart';
import '../../sheet/providers/sheet_view_model.dart';
import '../dialog/spell_bond_dialog.dart';
import '../dialog/spell_energy_dialog.dart';
import 'spell_widget.dart';
import 'package:provider/provider.dart';

class ListSpellsWidget extends StatefulWidget {
  final String title;
  final List<Spell> listSpells;
  final bool isDense;
  final bool isDraggable;
  final bool isMine;

  const ListSpellsWidget({
    super.key,
    required this.title,
    required this.listSpells,
    this.isDense = true,
    this.isDraggable = false,
    this.isMine = true,
  });

  @override
  State<ListSpellsWidget> createState() => _ListSpellsWidgetState();
}

class _ListSpellsWidgetState extends State<ListSpellsWidget> {
  List<Spell> listSpellVisualization = [];

  @override
  void initState() {
    super.initState();
    listSpellVisualization = widget.listSpells;
  }

  @override
  void didUpdateWidget(covariant ListSpellsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listSpells != widget.listSpells) {
      setState(() {
        listSpellVisualization = List.from(widget.listSpells);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);

    final userProvider = Provider.of<UserProvider>(context);
    Campaign? campaign = userProvider.getCampaignBySheet(sheetVM.sheet!.id);
    bool isResistedActive = sheetVM.isModuleActive(
      moduleId: Module.resisted.id,
      campaign: campaign,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            <Widget>[
              GenericHeader(title: widget.title, showDivider: false),
              GenericFilterWidget<Spell>(
                listValues: widget.listSpells,
                listOrderers: [
                  GenericFilterOrderer<Spell>(
                    label: "Energia",
                    iconAscending: Icons.flare,
                    iconDescending: Icons.abc,
                    orderFunction: (a, b) {
                      return a.energy.compareTo(b.energy);
                    },
                  ),
                  GenericFilterOrderer<Spell>(
                    label: "Nome",
                    iconAscending: Icons.abc,
                    iconDescending: Icons.abc,
                    orderFunction: (a, b) {
                      return a.name.compareTo(b.name);
                    },
                  ),
                ],
                onFiltered: (listFiltered) {
                  setState(() {
                    listSpellVisualization = listFiltered
                        .map((e) => e)
                        .toList();
                  });
                },
                textExtractor: (spell) =>
                    spell.name + spell.verbal + (spell.source ?? ""),
                enableSearch: true,
              ),
            ] +
            List.generate(listSpellVisualization.length, (index) {
              Spell spell = listSpellVisualization[index];
              return SpellWidget(
                spell: spell,
                isDense: widget.isDense,
                isDraggable: widget.isDraggable,
                onRoll:
                    (spell.actionIds.isNotEmpty &&
                        widget.isMine &&
                        spell.hasBaseTest)
                    ? () {
                        _rollActions(
                          spell: spell,
                          rollType: RollType.difficult,
                        );
                      }
                    : null,
                onRollResisted:
                    (spell.actionIds.isNotEmpty &&
                        widget.isMine &&
                        spell.isResisted)
                    ? () {
                        _rollActions(
                          spell: spell,
                          rollType: isResistedActive
                              ? RollType.resisted
                              : RollType.difficult,
                        );
                      }
                    : null,
                onTapRemove: (widget.isMine && sheetVM.isEditing)
                    ? () {
                        sheetVM.removeSpell(spell);
                      }
                    : null,
              );
            }),
      ),
    );
  }

  void _rollActions({required Spell spell, required RollType rollType}) async {
    SheetViewModel sheetVM = context.read<SheetViewModel>();

    if (sheetVM.getBoolean("isBonded") && spell.isBond) {
      bool? canRoll = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(child: SpellBondDialog(sheetVM: sheetVM));
        },
      );

      if (canRoll != true) return;
    }

    int energy = int.parse(spell.energy.replaceAll("+", ""));

    if (spell.energy.contains("+")) {
      if (!mounted) return;
      int? value = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(child: SpellEnergyDialog(minEnergy: energy));
        },
      );
      if (value != null) {
        energy = value;
      }
    }

    bool canCast = sheetVM.consumeEnergy(energy);

    if (!canCast) return;

    if (spell.actionIds.length == 1) {
      String id = spell.actionIds.first;
      ActionTemplate? action = sheetVM.actionRepo.getActionById(id);
      if (action != null) {
        if (!mounted) return;
        SheetInteract.rollAction(
          context: context,
          action: action,
          groupId: sheetVM.groupByAction(action.id)!,
          spell: spell,
          rollType: rollType,
        );
      }
    } else {
      for (String id in spell.actionIds) {
        ActionTemplate? action = sheetVM.actionRepo.getActionById(id);
        if (action != null) {
          if (!mounted) return;
          SheetInteract.rollAction(
            context: context,
            action: action,
            groupId: sheetVM.groupByAction(action.id)!,
            spell: spell,
            rollType: rollType,
          );
        }
      }
    }

    if (spell.isBond) {
      sheetVM.customCountInsert(
        SheetCustomCount(
          id: "bond",
          name: spell.name,
          description: "",
          count: 0,
        ),
      );

      sheetVM.setBoolean("isBonded", true);
    }
  }
}
