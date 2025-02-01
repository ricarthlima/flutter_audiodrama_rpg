import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/enum_action_train_level.dart';
import '../../models/action_template.dart';
import '../../models/sheet_model.dart';
import 'action_tooltip.dart';

class ActionWidget extends StatefulWidget {
  final ActionTemplate action;
  final SheetModel sheet;
  final bool isEditing;
  const ActionWidget({
    super.key,
    required this.action,
    required this.sheet,
    required this.isEditing,
  });

  @override
  State<ActionWidget> createState() => _ActionWidgetState();
}

class _ActionWidgetState extends State<ActionWidget> {
  OverlayEntry? _overlayEntry;
  ActionTrainLevel _trainLevel = ActionTrainLevel.semAptidao;
  int av = 0;

  @override
  void initState() {
    av = widget.sheet.listActionValue
        .firstWhere(
          (av) => av.actionId == widget.action.id,
          orElse: () => ActionValue(
            actionId: widget.action.id,
            value: 1,
          ),
        )
        .value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (!widget.isEditing) ? () {} : null,
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
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontFamily: "SourceSerif4"),
              ),
            ),
          ),
          Visibility(
            visible: (!widget.action.isFree && !widget.action.isPreparation) ||
                widget.action.isReaction ||
                widget.action.isResisted,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 1000),
              child: widget.isEditing
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
                        }
                      },
                    )
                  : Tooltip(
                      message: _tooltipText(av),
                      child: Row(
                        children: List.generate(
                          5,
                          (index) {
                            return Icon(
                              Icons.directions,
                              size: (av == index) ? 16 : 10,
                              color: (av == index) ? _getColor(av) : null,
                            );
                          },
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Color? _getColor(int av) {
    switch (av) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.greenAccent;
    }
    return null;
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
        left: offset.dx +
            renderBox.size.width / 2 -
            50, // Centraliza horizontalmente
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
}
