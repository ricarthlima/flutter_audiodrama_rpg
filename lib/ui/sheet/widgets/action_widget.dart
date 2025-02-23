import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/color_filter_inverter.dart';
import 'package:provider/provider.dart';

import '../../_core/theme_provider.dart';
import '../../../data/daos/action_dao.dart';
import '../helpers/enum_action_train_level.dart';
import '../../../domain/models/action_template.dart';
import '../../../domain/models/sheet_model.dart';
import '../components/action_dialog_tooltip.dart';
import '../view/sheet_view_model.dart';
import 'action_tooltip.dart';

class ActionWidget extends StatefulWidget {
  final ActionTemplate action;

  const ActionWidget({
    super.key,
    required this.action,
  });

  @override
  State<ActionWidget> createState() => _ActionWidgetState();
}

class _ActionWidgetState extends State<ActionWidget> {
  OverlayEntry? _overlayEntry;
  ActionTrainLevel _trainLevel = ActionTrainLevel.semAptidao;
  int av = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SheetViewModel>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    av = viewModel.sheet!.listActionValue
        .firstWhere(
          (av) => av.actionId == widget.action.id,
          orElse: () => ActionValue(
            actionId: widget.action.id,
            value: 1,
          ),
        )
        .value;

    _trainLevel = ActionTrainLevel.values[av];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: !viewModel.isEditing,
          child: ColorFiltered(
            colorFilter: getColorFilterInverter(
                themeProvider.themeMode == ThemeMode.dark),
            child: Tooltip(
              message: viewModel.getHelperText(widget.action),
              child: Image.asset(
                _getHelperImageByType(),
                height: 16,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        ),
        Visibility(
          visible: !viewModel.isEditing,
          child: SizedBox(width: 8),
        ),
        Flexible(
          child: InkWell(
            onTap: (!viewModel.isEditing)
                ? () {
                    rollAction();
                  }
                : null,
            onLongPress: () => showDialogTip(context, widget.action),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: MouseRegion(
                    onEnter: (PointerEnterEvent event) => _showTooltip(),
                    onExit: (PointerExitEvent event) => _hideTooltip(),
                    child: Text(
                      widget.action.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "SourceSerif4",
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      (!widget.action.isFree && !widget.action.isPreparation) ||
                          widget.action.isReaction ||
                          widget.action.isResisted,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 1000),
                    child: viewModel.isEditing
                        ? DropdownButton<ActionTrainLevel>(
                            value: _trainLevel,
                            isDense: true,
                            items: [
                              DropdownMenuItem(
                                value: ActionTrainLevel.aversao,
                                child: Text("Aversão"),
                              ),
                              DropdownMenuItem(
                                value: ActionTrainLevel.semAptidao,
                                child: Text("Sem aptidão"),
                              ),
                              DropdownMenuItem(
                                value: ActionTrainLevel.comAptidao,
                                child: Text("Com aptidão"),
                              ),
                              DropdownMenuItem(
                                value: ActionTrainLevel.treinado,
                                child: Text("Com treinamento"),
                              ),
                              DropdownMenuItem(
                                value: ActionTrainLevel.proposito,
                                child: Text("Propósito"),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _trainLevel = value;
                                });
                                viewModel.onActionValueChanged(
                                  ActionValue(
                                    actionId: widget.action.id,
                                    value: value.index,
                                  ),
                                );
                              }
                            },
                          )
                        : Tooltip(
                            message: _tooltipText(av),
                            child: Row(
                              children: List.generate(
                                5,
                                (index) {
                                  return Image.asset(
                                    (av == index)
                                        ? "assets/images/d20-$av.png"
                                        : (Provider.of<ThemeProvider>(context)
                                                    .themeMode ==
                                                ThemeMode.dark)
                                            ? "assets/images/d20.png"
                                            : "assets/images/d20i.png",
                                    width: (av == index) ? 14 : 10,
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void rollAction() {
    final viewModel = Provider.of<SheetViewModel>(context, listen: false);

    List<int> rolls = [];

    int newActionValue = av + (viewModel.modGlobalTrain);

    if (newActionValue < 0) {
      newActionValue = 0;
    }

    if (newActionValue > 4) {
      newActionValue = 4;
    }

    if (ActionDAO.instance.isOnlyFreeOrPreparation(widget.action.id)) {
      rolls.add(Random().nextInt(20) + 1);
    } else {
      if (newActionValue == 0 || newActionValue == 4) {
        rolls.add(Random().nextInt(20) + 1);
        rolls.add(Random().nextInt(20) + 1);
        rolls.add(Random().nextInt(20) + 1);
      } else if (newActionValue == 1 || newActionValue == 3) {
        rolls.add(Random().nextInt(20) + 1);
        rolls.add(Random().nextInt(20) + 1);
      } else if (newActionValue == 2) {
        rolls.add(Random().nextInt(20) + 1);
      }
    }

    viewModel.onRoll(
      context,
      roll: RollLog(
        rolls: rolls,
        idAction: widget.action.id,
        dateTime: DateTime.now(),
        isGettingLower: newActionValue <= 1,
      ),
    );
  }

  String _tooltipText(int av) {
    switch (av) {
      case 0:
        return "Aversão - Role 3d20, pegue o menor";
      case 1:
        return "Sem aptidão - Role 2d20, pegue o menor";
      case 2:
        return "Com aptidão - Role 1d20";
      case 3:
        return "Com treinamento - Role 2d20, pegue o maior";
      case 4:
        return "Propósito - Role 3d20, pegue o maior";
    }
    return "";
  }

  void _showTooltip() {
    if (_overlayEntry != null) return; // Evita múltiplos tooltips

    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx, // Centraliza horizontalmente
        top: offset.dy + renderBox.size.height + 8, // Abaixo do widget alvo
        child: Material(
          color: Colors.transparent,
          child: ActionTooltip(action: widget.action),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _getHelperImageByType() {
    String result = "assets/images/";
    if (widget.action.isFree || widget.action.isPreparation) {
      result += "free.png";
    } else {
      if (widget.action.isResisted) {
        result += "swords.png";
      } else {
        result += "dice.png";
      }
    }
    return result;
  }
}
