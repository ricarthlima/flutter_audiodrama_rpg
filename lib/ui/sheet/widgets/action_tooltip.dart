import 'package:flutter/material.dart';
import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
import '../../../domain/dto/action_template.dart';

class ActionTooltip extends StatelessWidget {
  final ActionTemplate action;
  final bool isEffortUsed;
  const ActionTooltip({
    super.key,
    required this.action,
    this.isEffortUsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                action.name,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: FontFamily.bungee,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Visibility(
                visible:
                    action.isFree ||
                    action.isPreparation ||
                    action.isReaction ||
                    action.isResisted,
                child: Text(
                  "($_generateModifiersText)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontFamily: FontFamily.sourceSerif4,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                action.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: FontFamily.sourceSerif4,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          Visibility(
            visible: isEffortUsed,
            child: Text(
              "ESFORÇO USADO",
              style: TextStyle(
                color: AppColors.red,
                fontFamily: FontFamily.bungee,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _generateModifiersText {
    String result = "";
    int count = 0;

    if (action.isFree) {
      result += "Livre ";
      count++;
    }
    if (action.isResisted) {
      result += "Resistida ";
      count++;
    }
    if (action.isReaction) {
      result += "Reação ";
      count++;
    }
    if (action.isPreparation) {
      result += "Preparação ";
      count++;
    }

    if (action.isCollective) {
      result += "Coletiva ";
      count++;
    }

    if (count > 1) {
      result = result.replaceAll(" ", ", ");
      result = result.substring(0, result.length - 2);
    } else {
      result = result.replaceAll(" ", "");
    }

    return result;
  }
}
