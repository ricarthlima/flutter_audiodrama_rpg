import 'package:flutter/material.dart';

import '../dimensions.dart';

class VerticalCompactableArea extends StatefulWidget {
  final Widget title;
  final Widget child;

  const VerticalCompactableArea({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  State<VerticalCompactableArea> createState() =>
      _VerticalCompactableAreaState();
}

class _VerticalCompactableAreaState extends State<VerticalCompactableArea> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.title,
              IconButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                icon: Icon(isExpanded
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 250,
          height: isExpanded ? height(context) * 0.8 : 0,
          curve: Curves.ease,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: Theme.of(context).textTheme.bodyMedium!.color!),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: widget.child,
        ),
      ],
    );
  }
}
