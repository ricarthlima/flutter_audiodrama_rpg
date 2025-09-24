import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';

class StackDialog extends StatelessWidget {
  final Widget child;
  final Function onDismiss;
  final Color barrierColor;
  final int barrierAlpha;
  const StackDialog({
    super.key,
    required this.onDismiss,
    this.barrierColor = Colors.black,
    this.barrierAlpha = 130,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            onDismiss();
          },
          child: Container(
            width: width(context),
            height: height(context),
            color: barrierColor.withAlpha(barrierAlpha),
            child: Text(""),
          ),
        ),
        Align(alignment: Alignment.center, child: child),
      ],
    );
  }
}
