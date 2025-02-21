import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/domain/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';

Future<dynamic> showRollDialog({
  required BuildContext context,
  required RollLog rollLog,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: RollRowWidget(rollLog: rollLog),
      );
    },
  );
}

class RollRowWidget extends StatefulWidget {
  final RollLog rollLog;
  const RollRowWidget({
    super.key,
    required this.rollLog,
  });

  @override
  State<RollRowWidget> createState() => _RollRowWidgetState();
}

class _RollRowWidgetState extends State<RollRowWidget> {
  int i = 0;
  List<double> listOpacity = [0, 0, 0];
  bool isShowingHighlighted = false;

  @override
  void initState() {
    super.initState();
    callShowRoll();
  }

  callShowRoll() async {
    await Future.delayed(Duration(milliseconds: 250));
    setState(() {
      listOpacity[i] = 1;
    });
    i++;
    if (i < widget.rollLog.rolls.length) {
      callShowRoll();
    } else {
      makeCorrectHighlighted();
    }
  }

  makeCorrectHighlighted() async {
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() {
      isShowingHighlighted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: isVertical(context) ? 32 : 64,
        runSpacing: isVertical(context) ? 32 : 64,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        children: List.generate(
          widget.rollLog.rolls.length,
          (index) {
            return AnimatedOpacity(
              opacity: listOpacity[index],
              duration: Duration(milliseconds: 750),
              child: SizedBox(
                width: isVertical(context) ? 128 : 256,
                height: isVertical(context) ? 128 : 256,
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 750),
                      child: Image.asset(
                        (!isShowingHighlighted)
                            ? "assets/images/d20-1.png"
                            : (ActionDAO.instance
                                        .getActionById(widget.rollLog.idAction)!
                                        .isResisted &&
                                    !widget.rollLog.isGettingLower)
                                ? (widget.rollLog.rolls[index] >= 10)
                                    ? "assets/images/d20-4.png"
                                    : "assets/images/d20-0.png"
                                : (ActionDAO.instance
                                            .getActionById(
                                                widget.rollLog.idAction)!
                                            .isResisted &&
                                        widget.rollLog.isGettingLower)
                                    ? (widget.rollLog.rolls.reduce(min) ==
                                                widget.rollLog.rolls[index] &&
                                            widget.rollLog.rolls[index] >= 10)
                                        ? "assets/images/d20-4.png"
                                        : "assets/images/d20-0.png"
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
          },
        ),
      ),
    );
  }
}
