import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/dimensions.dart';

class CompactableButton extends StatefulWidget {
  final CompactableButtonController controller;
  final String? title;
  final IconData? leadingIcon;
  final Function onPressed;

  final Widget? leading;
  final Widget? child;

  const CompactableButton({
    super.key,
    required this.controller,
    required this.onPressed,
    this.title,
    this.leadingIcon,
    this.leading,
    this.child,
  });

  @override
  State<CompactableButton> createState() => _CompactableButtonState();
}

class _CompactableButtonState extends State<CompactableButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onPressed.call(),
      child: MouseRegion(
        onEnter: (event) => setState(() {
          isHovering = true;
        }),
        onExit: (event) => setState(() {
          isHovering = false;
        }),
        child: TweenAnimationBuilder<double>(
            duration: Duration(
              milliseconds: !widget.controller.isCompressed ? 750 : 0,
            ),
            tween: Tween<double>(
              begin: widget.controller.isCompressed ? 0 : 1,
              end: !widget.controller.isCompressed ? 1 : 0,
            ),
            curve: Curves.ease,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 500),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (widget.controller.isSelected || isHovering)
                      ? Colors.grey.withAlpha(75)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SizedBox(
                  width: ((isVertical(context)) ? 0 : 32) +
                      (value * ((isVertical(context)) ? 275 : 243)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.leading == null && widget.leadingIcon != null)
                        Tooltip(
                          message: widget.title ?? "",
                          child: Icon(widget.leadingIcon),
                        ),
                      if (widget.leading != null) widget.leading!,
                      if (value > 0.2 && !widget.controller.isCompressed)
                        SizedBox(width: 8),
                      if (widget.child == null &&
                          widget.title != null &&
                          value > 0.2 &&
                          !widget.controller.isCompressed)
                        SizedBox(
                          width: 0 + (value * 180),
                          child: Text(
                            widget.title!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.child != null &&
                          value > 0.2 &&
                          !widget.controller.isCompressed)
                        SizedBox(
                          width: 0 + (value * 180),
                          child: widget.child!,
                        )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class CompactableButtonController {
  bool isCompressed;
  bool isSelected;

  CompactableButtonController({
    required this.isCompressed,
    required this.isSelected,
  });
}
