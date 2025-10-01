import 'package:flutter/material.dart';

class HorizontalSplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final double dividerThickness;
  final double spacing;
  final Duration animationDuration;
  final Curve animationCurve;
  final double dragSensitivity;

  final Function(double ratio)? onChange;

  const HorizontalSplitView({
    super.key,
    required this.left,
    required this.right,
    this.initialRatio = 0.5,
    this.minRatio = 0.15,
    this.maxRatio = 0.85,
    this.dividerThickness = 6,
    this.spacing = 12,
    this.animationDuration = const Duration(milliseconds: 120),
    this.animationCurve = Curves.easeOut,
    this.dragSensitivity = 8,
    this.onChange,
  });

  @override
  State<HorizontalSplitView> createState() => _HorizontalSplitViewState();
}

class _HorizontalSplitViewState extends State<HorizontalSplitView> {
  late double ratio;

  @override
  void initState() {
    super.initState();
    ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
  }

  @override
  void didUpdateWidget(covariant HorizontalSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRatio != widget.initialRatio) {
      setState(() {
        ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final double w = constraints.maxWidth;
        final double usable = w - widget.dividerThickness - widget.spacing * 2;
        final double leftW = (usable * ratio).clamp(
          usable * widget.minRatio,
          usable * widget.maxRatio,
        );
        final double rightW = usable - leftW;

        return Row(
          children: [
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              width: leftW,
              child: widget.left,
            ),
            if (widget.spacing > 0) SizedBox(width: widget.spacing),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (d) {
                final double newRatio =
                    (leftW + d.delta.dx * widget.dragSensitivity) / usable;
                setState(() {
                  ratio = newRatio.clamp(widget.minRatio, widget.maxRatio);
                });
                if (widget.onChange != null) {
                  widget.onChange!(ratio);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(
                  width: widget.dividerThickness,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
            if (widget.spacing > 0) SizedBox(width: widget.spacing),
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              width: rightW,
              child: widget.right,
            ),
          ],
        );
      },
    );
  }
}
