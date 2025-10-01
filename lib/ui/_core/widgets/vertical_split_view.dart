import 'package:flutter/material.dart';

class VerticalSplitView extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final double dividerThickness;
  final double spacing;
  final Duration animationDuration;
  final Curve animationCurve;
  final double dragSensitivity;
  final Function(double ratio)? onChange;

  const VerticalSplitView({
    super.key,
    required this.top,
    required this.bottom,
    this.initialRatio = 0.75,
    this.minRatio = 0.15,
    this.maxRatio = 0.9,
    this.dividerThickness = 6,
    this.spacing = 0,
    this.animationDuration = const Duration(milliseconds: 120),
    this.animationCurve = Curves.easeOut,
    this.dragSensitivity = 0.5,
    this.onChange,
  });

  @override
  State<VerticalSplitView> createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  late double ratio;

  @override
  void initState() {
    super.initState();
    ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
  }

  @override
  void didUpdateWidget(covariant VerticalSplitView oldWidget) {
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
        final double h = constraints.maxHeight;
        final double usable = h - widget.dividerThickness - widget.spacing * 2;
        final double topH = (usable * ratio).clamp(
          usable * widget.minRatio,
          usable * widget.maxRatio,
        );
        final double bottomH = usable - topH;

        return Column(
          children: [
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              height: topH,
              child: widget.top,
            ),
            if (widget.spacing > 0) SizedBox(height: widget.spacing),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (d) {
                final double newRatio =
                    (topH + d.delta.dy * widget.dragSensitivity) / usable;
                setState(() {
                  ratio = newRatio.clamp(widget.minRatio, widget.maxRatio);
                });
                if (widget.onChange != null) {
                  widget.onChange!(ratio);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: Container(
                  height: widget.dividerThickness,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (widget.spacing > 0) SizedBox(height: widget.spacing),
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              height: bottomH,
              child: widget.bottom,
            ),
          ],
        );
      },
    );
  }
}
