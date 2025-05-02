import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/action_template.dart';
import '../../../domain/models/roll_log.dart';
import '../../_core/dimensions.dart';
import '../../_core/fonts.dart';
import '../view/sheet_view_model.dart';

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
    final viewModel = Provider.of<SheetViewModel>(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
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
            style: TextStyle(
              fontSize: 32,
              fontFamily: FontFamily.bungee,
            ),
          ),
          Wrap(
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
                                : (context
                                            .read<SheetViewModel>()
                                            .actionRepo
                                            .getActionById(
                                                widget.rollLog.idAction)!
                                            .isResisted &&
                                        !widget.rollLog.isGettingLower)
                                    ? (widget.rollLog.rolls[index] >= 10)
                                        ? "assets/images/d20-2.png"
                                        : "assets/images/d20-1.png"
                                    : (context
                                                .read<SheetViewModel>()
                                                .actionRepo
                                                .getActionById(
                                                    widget.rollLog.idAction)!
                                                .isResisted &&
                                            widget.rollLog.isGettingLower)
                                        ? (widget.rollLog.rolls.reduce(min) ==
                                                    widget
                                                        .rollLog.rolls[index] &&
                                                widget.rollLog.rolls[index] >=
                                                    10)
                                            ? "assets/images/d20-2.png"
                                            : "assets/images/d20-1.png"
                                        : (widget.rollLog.isGettingLower)
                                            ? (widget.rollLog.rolls
                                                        .reduce(min) ==
                                                    widget.rollLog.rolls[index])
                                                ? "assets/images/d20-0.png"
                                                : "assets/images/d20-1.png"
                                            : (widget.rollLog.rolls
                                                        .reduce(max) ==
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
          if (context
              .read<SheetViewModel>()
              .actionRepo
              .getActionById(widget.rollLog.idAction)!
              .isResisted)
            AnimatedOpacity(
              duration: Duration(milliseconds: 750),
              opacity: (context
                          .read<SheetViewModel>()
                          .actionRepo
                          .getActionById(widget.rollLog.idAction)!
                          .isResisted &&
                      isShowingHighlighted)
                  ? 1
                  : 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Você obteve ",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      _calculateAmountSuccess().toString(),
                      style: TextStyle(fontSize: 48),
                    ),
                    Text(
                      " sucesso",
                      style: TextStyle(fontSize: 24),
                    ),
                    if (_calculateAmountSuccess() != 1)
                      Text(
                        "s",
                        style: TextStyle(fontSize: 24),
                      ),
                    Text(
                      ".",
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            viewModel.getHelperText(context
                .read<SheetViewModel>()
                .actionRepo
                .getActionById(widget.rollLog.idAction)!),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _calculateAmountSuccess() {
    ActionTemplate action = context
        .read<SheetViewModel>()
        .actionRepo
        .getActionById(widget.rollLog.idAction)!;

    if (action.isResisted) {
      if (widget.rollLog.isGettingLower) {
        int roll = widget.rollLog.rolls
            .reduce((current, next) => (current) < next ? current : next);
        if (roll >= 10) return 1;
      } else {
        List<int> rolls = widget.rollLog.rolls.where((e) => e >= 10).toList();
        return rolls.length;
      }
    }

    return 0;
  }
}
