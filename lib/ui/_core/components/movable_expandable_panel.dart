import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MovableExpandablePanel extends StatefulWidget {
  final String headerTitle;
  final Widget child;

  const MovableExpandablePanel({
    super.key,
    required this.headerTitle,
    required this.child,
  });

  @override
  State<MovableExpandablePanel> createState() => _MovableExpandablePanelState();
}

class _MovableExpandablePanelState extends State<MovableExpandablePanel> {
  late Offset position;
  bool expanded = true;
  double scaleFactor = 0.75;
  double contentWidth = 300;
  double contentHeight = 200;
  bool _initializedPosition = false;

  @override
  void initState() {
    super.initState();
    position = const Offset(0, 0); // temporário
  }

  void _updateScale(double delta) {
    setState(() {
      scaleFactor = (scaleFactor + delta).clamp(0.1, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final delta = event.scrollDelta.dy;
            _updateScale(-delta * 0.0002);
          }
        },
        child: GestureDetector(
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2 && details.scale != 1.0) {
              _updateScale(details.scale - 1);
            } else if (details.pointerCount == 1 &&
                details.scale == 1.0 &&
                details.focalPointDelta.distance != 0) {
              setState(() {
                position += details.focalPointDelta;
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
                child: Container(
                  width: expanded ? contentWidth * scaleFactor : null,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: expanded
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Theme.of(context)
                            .scaffoldBackgroundColor
                            .withAlpha(50),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.headerTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          expanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            expanded = !expanded;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Transform.scale(
                      scale: scaleFactor,
                      alignment: Alignment.topLeft,
                      child: MeasureSize(
                        onChange: (size) {
                          if (size != null) {
                            setState(() {
                              contentWidth = size.width;
                              contentHeight = size.height;

                              if (!_initializedPosition) {
                                final screenSize = MediaQuery.of(context).size;
                                final maxWidth = screenSize.width * 0.4;
                                final maxHeight = screenSize.height * 0.4;

                                final double initialScaleX =
                                    maxWidth / contentWidth;
                                final double initialScaleY =
                                    maxHeight / contentHeight;
                                scaleFactor = initialScaleX < initialScaleY
                                    ? initialScaleX
                                    : initialScaleY;
                                scaleFactor = scaleFactor.clamp(0.1, 1.0);

                                position = Offset(
                                  (screenSize.width -
                                          contentWidth * scaleFactor) /
                                      2,
                                  (screenSize.height -
                                          contentHeight * scaleFactor) /
                                      2,
                                );
                                _initializedPosition = true;
                              }
                            });
                          }
                        },
                        child: widget.child,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size? size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final _key = GlobalKey();
  Size? oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextBox = _key.currentContext;
      if (contextBox == null) return;

      final size = contextBox.size;
      if (size != oldSize) {
        oldSize = size;
        widget.onChange(size);
      }
    });

    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
