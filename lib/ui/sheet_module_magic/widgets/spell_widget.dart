import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../_core/providers/user_provider.dart';
import '../../../data/services/chat_service.dart';
import '../../../domain/dto/spell.dart';
import '../../../domain/models/campaign.dart';
import '../../_core/app_colors.dart';
import '../../_core/color_filter_inverter.dart';
import '../../_core/constants/helper_image_path.dart';
import '../../_core/fonts.dart';
import '../../sheet/providers/sheet_view_model.dart';

class SpellWidget extends StatefulWidget {
  final Spell spell;
  final Function? onRoll;
  final Function? onRollResisted;
  final Function? onTapRemove;
  final Function(String)? onTapAction;
  final Function(String)? onTapTag;
  final bool isDense;
  final bool isDraggable;
  const SpellWidget({
    super.key,
    required this.spell,
    this.onTapRemove,
    this.onRoll,
    this.onRollResisted,
    this.onTapAction,
    this.onTapTag,
    this.isDense = false,
    this.isDraggable = false,
  });

  @override
  State<SpellWidget> createState() => _SpellWidgetState();
}

class _SpellWidgetState extends State<SpellWidget> {
  bool isExpanded = false;

  @override
  void initState() {
    isExpanded = !widget.isDense;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SheetViewModel sheetVM = Provider.of<SheetViewModel>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    Campaign? campaign = userProvider.getCampaignBySheet(sheetVM.sheet!.id);

    return InkWell(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    if (widget.onRollResisted != null && !sheetVM.isEditing)
                      Tooltip(
                        message:
                            "Conjure feitiços contra individuos que resistem.",
                        child: InkWell(
                          onTap: () {
                            widget.onRollResisted!();
                          },
                          child: ColorFiltered(
                            colorFilter: colorFilterRed,
                            child: Image.asset(
                              HelperImagePath.sword,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    if (widget.onRoll != null && !sheetVM.isEditing)
                      Tooltip(
                        message: "Determine a potência do feitiço.",
                        child: InkWell(
                          onTap: () {
                            widget.onRoll!();
                          },
                          child: ColorFiltered(
                            colorFilter: colorFilterRed,
                            child: Image.asset(
                              HelperImagePath.dice,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    IgnorePointer(
                      ignoring: !widget.isDraggable,
                      child: Draggable<Spell>(
                        feedback: Material(child: _buildTitle()),

                        data: widget.spell,
                        child: _buildTitle(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (campaign != null)
                      IconButton(
                        onPressed: () {
                          _sendToChat(sheetVM, campaign);
                        },
                        icon: Icon(Icons.chat),
                      ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ),
                    if (widget.onTapRemove != null)
                      IconButton(
                        onPressed: () {
                          widget.onTapRemove!();
                        },
                        icon: Icon(Icons.delete, color: AppColors.red),
                      ),
                  ],
                ),
              ],
            ),
            if (isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  actions,
                  Text(widget.spell.description),
                  Opacity(
                    opacity: 0.75,
                    child: Text(
                      "$_range $_bond",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (widget.spell.source != null) source,
                  tags,
                ],
              ),
          ],
        ),
      ),
    );
  }

  String get _range => "Alcance: ${widget.spell.range}.";

  String get _bond => "Vínculo? ${_boolToSim(widget.spell.isBond)}.";

  String _boolToSim(bool value) {
    if (value) {
      return "Sim";
    }
    return "Não";
  }

  Row _buildTitle() {
    return Row(
      children: [
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            Text(
              "(${widget.spell.energy}) ${(widget.spell.isBond) ? '(V)' : ''} ${widget.spell.name}",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              "(${widget.spell.verbal})",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            if (widget.spell.isBeta)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: AppColors.red,
                child: Text(
                  "BETA",
                  style: TextStyle(
                    fontFamily: FontFamily.bungee,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget get leading {
    String tooltip = "";
    Widget icon = Icon(Icons.auto_awesome);
    double size = 16;

    switch (widget.spell.name.split(" ").first) {
      case "Feitiço":
        {
          tooltip = "Feitiços são a forma mais comum de magia.";
          icon = FaIcon(FontAwesomeIcons.wandMagicSparkles, size: size);
        }
      case "Truque":
        {
          tooltip = "Truques são feitiços simples de baixo custo mágico.";
          icon = FaIcon(FontAwesomeIcons.starAndCrescent, size: size);
        }
      case "Graça":
        {
          tooltip = "Graças são feitiços de cura e proteção.";
          icon = Icon(Icons.flare, size: size);
        }
      case "Praga":
        {
          tooltip = "Pragas são feitiços poderosos e imperdoáveis.";
          icon = FaIcon(FontAwesomeIcons.hatWizard, size: size);
        }
    }
    return Tooltip(message: tooltip, child: icon);
  }

  Widget get actions {
    return Wrap(
      spacing: 4,
      children: List.generate(widget.spell.actions.length, (index) {
        Color color = AppColors.spellMagiaBruta;
        String action = widget.spell.actions[index];
        switch (action) {
          case "Magia-Bruta":
            color = AppColors.spellMagiaBruta;
          case "Limiar":
            color = AppColors.spellLimiar;
          case "Engano":
            color = AppColors.spellEngano;
          case "Senciência":
            color = AppColors.spellSenciencia;
          case "Asilo":
            color = AppColors.spellAsilo;
          case "Magia-Elemental":
            color = AppColors.spellMagiaElemental;
          case "Metamorfose":
            color = AppColors.spellMetamorfose;
        }
        return InkWell(
          onTap: widget.onTapAction != null
              ? () {
                  widget.onTapAction!(action);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color,
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              action,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget get tags {
    return Wrap(
      spacing: 4,
      children: List.generate(widget.spell.tags.length, (index) {
        String tag = widget.spell.tags[index];
        return InkWell(
          onTap: widget.onTapAction != null ? widget.onTapAction!(tag) : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.white),
            ),
            child: Text(tag, style: TextStyle(fontSize: 8)),
          ),
        );
      }),
    );
  }

  Widget get source {
    return Opacity(
      opacity: 0.75,
      child: Text(
        "Fonte: ${widget.spell.source!}",
        style: TextStyle(fontSize: 11),
      ),
    );
  }

  void _sendToChat(SheetViewModel sheetVM, Campaign campaign) {
    ChatService.instance.sendMessageToChat(
      campaignId: campaign.id,
      message:
          """
# (${widget.spell.energy}) ${widget.spell.name}
${widget.spell.description}

${widget.spell.actions.reduce((value, element) => value += " | $element")}

**$_range**

**$_bond**

${widget.spell.tags.reduce((value, element) => value += element)}
          """,
    );
  }
}
