import 'package:flutter/material.dart';
import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';

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
        child: _RollBodyDialog(isSerious: isSerious, roll: roll),
      );
    },
  );
}

class _RollBodyDialog extends StatefulWidget {
  final int roll;
  final bool isSerious;

  const _RollBodyDialog({required this.isSerious, required this.roll});

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
                            textAlign: TextAlign.center,
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
            child: Text((isShowingInfo) ? "Ocultar" : "Revelar"),
          ),
        ],
      ),
    );
  }

  String _bodyPartByResult() {
    switch (widget.roll) {
      case 1:
        return (!widget.isSerious) ? "Rosto" : "Crânio";
      case 2:
        return (!widget.isSerious) ? "Pescoço" : "Carótida";
      case 3:
        return (!widget.isSerious) ? "Peito" : "Coração";
      case 4:
        return (!widget.isSerious) ? "Costelas" : "Pulmão";
      case 5:
        return (!widget.isSerious) ? "Abdômen superior" : "Fígado";
      case 6:
        return (!widget.isSerious) ? "Flanco" : "Baço";
      case 7:
        return (!widget.isSerious) ? "Quadril" : "Pelve";
      case 8:
        return (!widget.isSerious) ? "Virilha" : "Artéria femoral";
      case 9:
        return (!widget.isSerious) ? "Coxa externa" : "Coxa interna";
      case 10:
        return (!widget.isSerious) ? "Joelho" : "Ligamentos do joelho";
      case 11:
        return (!widget.isSerious) ? "Canela" : "Tíbia";
      case 12:
        return (!widget.isSerious) ? "Panturrilha" : "Tendão de Aquiles";
      case 13:
        return (!widget.isSerious) ? "Antebraço" : "Artéria radial";
      case 14:
        return (!widget.isSerious) ? "Braço" : "Nervo ulnar";
      case 15:
        return (!widget.isSerious) ? "Ombro" : "Plexo braquial";
      case 16:
        return (!widget.isSerious) ? "Mão" : "Dedos e tendões";
      case 17:
        return (!widget.isSerious) ? "Pé" : "Tornozelo";
      case 18:
        return (!widget.isSerious) ? "Nádega" : "Sacro";
      case 19:
        return (!widget.isSerious) ? "Costas" : "Coluna lombar";
      case 20:
        return (!widget.isSerious) ? "Cabeça lateral" : "Olho";
    }
    return "?";
  }
}
