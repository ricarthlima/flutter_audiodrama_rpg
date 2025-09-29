import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../_core/color_filter_inverter.dart';
import '../../_core/constants/helper_image_path.dart';
import 'package:provider/provider.dart';

import '../../../domain/dto/spell.dart';
import '../../../domain/models/roll_log.dart';
import '../../_core/constants/roll_type.dart';
import '../../_core/fonts.dart';
import '../providers/sheet_view_model.dart';

class MultipleRollDialog extends StatelessWidget {
  final List<RollLog> listRollLog;
  const MultipleRollDialog({super.key, required this.listRollLog});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(listRollLog.length, (index) {
        return Transform.scale(
          scale: listRollLog.length > 1 ? 0.75 : 1,
          child: RollStackDialog(rollLog: listRollLog[index]),
        );
      }),
    );
  }
}

class RollStackDialog extends StatefulWidget {
  final RollLog rollLog;
  const RollStackDialog({super.key, required this.rollLog});

  @override
  State<RollStackDialog> createState() => _RollStackDialogState();
}

class _RollStackDialogState extends State<RollStackDialog> {
  int i = 0;
  List<double> listOpacity = [0, 0, 0];
  bool isShowingHighlighted = false;

  Timer? timerHighlight;
  Timer? timerShowRoll;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callShowRoll();
    });
    super.initState();
  }

  @override
  void dispose() {
    timerHighlight?.cancel();
    timerShowRoll?.cancel();
    super.dispose();
  }

  Future<void> callShowRoll() async {
    timerShowRoll = Timer(Duration(milliseconds: 250), () {
      setState(() {
        listOpacity[i] = 1;
      });
      i++;
      if (i < widget.rollLog.rolls.length) {
        callShowRoll();
      } else {
        makeCorrectHighlighted();
      }
    });
  }

  void makeCorrectHighlighted() {
    timerHighlight = Timer(Duration(milliseconds: 1500), () {
      setState(() {
        isShowingHighlighted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetVM = Provider.of<SheetViewModel>(context);

    Spell? spell;
    if (widget.rollLog.idSpell != null) {
      spell = sheetVM.spellRepo.getById(widget.rollLog.idSpell!);
    }
    return Container(
      constraints: BoxConstraints(minWidth: 500),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(225),
        borderRadius: BorderRadius.zero,
        border: Border.all(width: 5, color: Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            context
                .read<SheetViewModel>()
                .actionRepo
                .getAllActions()
                .where((e) => e.id == widget.rollLog.idAction)
                .first
                .name,
            style: TextStyle(fontSize: 32, fontFamily: FontFamily.bungee),
          ),

          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: List.generate(widget.rollLog.rolls.length, (index) {
              return AnimatedOpacity(
                opacity: listOpacity[index],
                duration: Duration(milliseconds: 750),
                child: SizedBox(
                  width: 128,
                  height: 128,
                  child: Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 750),
                        child: Image.asset(
                          (!isShowingHighlighted)
                              ? "assets/images/d20-1.png"
                              : (widget.rollLog.rollType == RollType.resisted &&
                                    !widget.rollLog.isGettingLower)
                              ? (widget.rollLog.rolls[index] >= 10)
                                    ? "assets/images/d20-2.png"
                                    : "assets/images/d20-1.png"
                              : (widget.rollLog.rollType == RollType.resisted &&
                                    widget.rollLog.isGettingLower)
                              ? (widget.rollLog.rolls.reduce(min) ==
                                            widget.rollLog.rolls[index] &&
                                        widget.rollLog.rolls[index] >= 10)
                                    ? "assets/images/d20-2.png"
                                    : "assets/images/d20-1.png"
                              : (widget.rollLog.isGettingLower)
                              ? (widget.rollLog.rolls.reduce(min) ==
                                        widget.rollLog.rolls[index])
                                    ? "assets/images/d20-0.png"
                                    : "assets/images/d20-1.png"
                              : (widget.rollLog.rolls.reduce(max) ==
                                    widget.rollLog.rolls[index])
                              ? "assets/images/d20-4.png"
                              : "assets/images/d20-1.png",
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.rollLog.rolls[index].toString(),
                          style: TextStyle(
                            fontSize: 44,
                            fontFamily: FontFamily.bungee,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (widget.rollLog.rollType == RollType.resisted)
            AnimatedOpacity(
              duration: Duration(milliseconds: 750),
              opacity:
                  (widget.rollLog.rollType == RollType.resisted &&
                      isShowingHighlighted)
                  ? 1
                  : 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Você obteve ", style: TextStyle(fontSize: 24)),
                  Text(
                    _calculateAmountSuccess().toString(),
                    style: TextStyle(fontSize: 48),
                  ),
                  Text(" sucesso", style: TextStyle(fontSize: 24)),
                  if (_calculateAmountSuccess() != 1)
                    Text("s", style: TextStyle(fontSize: 24)),
                  Text(".", style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          if (spell != null)
            Container(
              constraints: BoxConstraints(
                minWidth: 400,
                maxWidth: 400,
                maxHeight: 200,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      spell.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(spell.description, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          SizedBox(width: 300, child: Divider()),
          SizedBox(
            width: 300,
            child: Opacity(
              opacity: 0.40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  ColorFiltered(
                    colorFilter: colorFilterInverter,
                    child: Image.asset(
                      (widget.rollLog.rollType == RollType.difficult)
                          ? HelperImagePath.dice
                          : HelperImagePath.sword,
                      width: 32,
                      height: 32,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      sheetVM.getHelperText(
                        context.read<SheetViewModel>().actionRepo.getActionById(
                          widget.rollLog.idAction,
                        )!,
                        widget.rollLog.rollType,
                      ),
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAmountSuccess() {
    int amount = 0;

    if (widget.rollLog.rollType == RollType.resisted) {
      if (widget.rollLog.isGettingLower) {
        int roll = widget.rollLog.rolls.reduce(
          (current, next) => (current) < next ? current : next,
        );
        if (roll >= 10) {
          amount = 1;
        }
      } else {
        List<int> rolls = widget.rollLog.rolls.where((e) => e >= 10).toList();
        amount = rolls.length;
      }
    }

    // Críticos
    int naturalOne = widget.rollLog.rolls.where((e) => e == 1).length;
    int naturalTwenty = widget.rollLog.rolls.where((e) => e == 20).length;

    amount = (amount - naturalOne) + naturalTwenty;

    return max(0, amount);
  }

  String typeName(RollType rolltype) {
    switch (rolltype) {
      case RollType.free:
        return "Livre";
      case RollType.prepared:
        return "Preparado";
      case RollType.resisted:
        return "Teste Resistido";
      case RollType.difficult:
        return "Teste de Dificuldade";
    }
  }
}
