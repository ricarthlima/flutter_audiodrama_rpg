import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/data/sheet_template.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/action_template.dart';

import '../../models/sheet_model.dart';

class RollLogWidget extends StatefulWidget {
  final RollLog rollLog;
  const RollLogWidget({super.key, required this.rollLog});

  @override
  State<RollLogWidget> createState() => _RollLogWidgetState();
}

class _RollLogWidgetState extends State<RollLogWidget> {
  @override
  Widget build(BuildContext context) {
    ActionTemplate? action =
        SheetDAO.instance.getActionById(widget.rollLog.idAction);

    if (action != null) {
      return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              action.name,
              style: TextStyle(
                fontFamily: FontFamilies.bungee,
              ),
            ),
            ExpansionTile(
              title: Text(
                "Descrição",
                style: TextStyle(
                  fontFamily: FontFamilies.sourceSerif4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              dense: true,
              tilePadding: EdgeInsets.zero,
              children: [
                Text(action.description),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.rollLog.rolls
                  .map(
                    (e) => _DiceRoll(
                      roll: e,
                      rolls: widget.rollLog.rolls,
                      isGettingLower: widget.rollLog.isGettingLower,
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16),
            Text(
              widget.rollLog.dateTime.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: FontFamilies.sourceSerif4,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}

class _DiceRoll extends StatelessWidget {
  final int roll;
  final List<int> rolls;
  final bool isGettingLower;
  const _DiceRoll({
    required this.roll,
    required this.rolls,
    required this.isGettingLower,
  });

  @override
  Widget build(BuildContext context) {
    bool isCondition = (isGettingLower)
        ? rolls.reduce(min) == roll
        : rolls.reduce(max) == roll;

    return Text(
      roll.toString(),
      style: TextStyle(
        fontSize: !isCondition ? 16 : 24,
        color: (isCondition)
            ? (isGettingLower)
                ? Colors.red[900]
                : Colors.green[900]
            : Theme.of(context).textTheme.bodyMedium!.color!,
        // fontWeight: FontWeight.bold,
        fontFamily: FontFamilies.bungee,
      ),
    );
  }
}
