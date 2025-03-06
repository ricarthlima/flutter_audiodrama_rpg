import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

import '../../_core/dimensions.dart';

Future<dynamic> showRollBodyDialog({
  required BuildContext context,
  required int roll,
  required bool isSerious,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: _RollBodyDialog(
          isSerious: isSerious,
          roll: roll,
        ),
      );
    },
  );
}

class _RollBodyDialog extends StatefulWidget {
  final int roll;
  final bool isSerious;

  const _RollBodyDialog({
    required this.isSerious,
    required this.roll,
  });

  @override
  State<_RollBodyDialog> createState() => __RollBodyDialogState();
}

class __RollBodyDialogState extends State<_RollBodyDialog> {
  bool isShowingInfo = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            (widget.isSerious)
                ? "Dano 'grave' ao corpo"
                : "Dano 'leve' ao corpo",
            style: TextStyle(
              fontSize: 24,
              fontFamily: FontFamily.bungee,
              color: Colors.white,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.easeIn,
            duration: Duration(seconds: 2),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: SizedBox(
                  width: isVertical(context) ? 128 : 256,
                  height: isVertical(context) ? 128 : 256,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: (!isShowingInfo)
                        ? Stack(
                            children: [
                              Image.asset("assets/images/d20-0.png"),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.roll.toString(),
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontFamily: FontFamily.bungee,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _bodyPartByResult(),
                            style: TextStyle(
                              fontSize: 44,
                              fontFamily: FontFamily.bungee,
                              color: AppColors.red,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isShowingInfo = !isShowingInfo;
              });
            },
            child: Text(
              (isShowingInfo) ? "Ocultar" : "Revelar",
            ),
          ),
        ],
      ),
    );
  }

  String _bodyPartByResult() {
    switch (widget.roll) {
      case 1:
        return (!widget.isSerious) ? "Braço" : "Cabeça";
      case 2:
        return (!widget.isSerious) ? "Pé" : "Coração";
      case 3:
        return (!widget.isSerious) ? "Mão" : "Femoral";
      case 4:
        return (!widget.isSerious) ? "Ombro" : "Pescoço";
      case 5:
        return (!widget.isSerious) ? "Perna" : "Torax (não coração)";
      case 6:
        return (!widget.isSerious) ? "Nádega" : "Abdômen";
    }
    return "?";
  }
}
