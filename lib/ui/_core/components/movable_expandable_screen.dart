import 'dart:math';

import 'package:flutter/material.dart';

class MovableExpandableScreen extends StatefulWidget {
  final Widget child;
  final String title;
  final double initialScale;
  final double minScale;
  final double maxScale;
  final Function? onPopup;
  final Function()? onExit;

  final double? width;
  final double? height;

  const MovableExpandableScreen({
    super.key,
    this.initialScale = 0.5,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.onPopup,
    this.onExit,
    this.width,
    this.height,
    required this.title,
    required this.child,
  });

  @override
  State<MovableExpandableScreen> createState() =>
      _MovableExpandableScreenState();
}

class _MovableExpandableScreenState extends State<MovableExpandableScreen> {
  Offset position = const Offset(100, 100);
  late double scale;
  bool expanded = true;

  @override
  void initState() {
    super.initState();
    scale = widget.initialScale;
  }

  void _increaseScale() {
    setState(() {
      scale = (scale + 0.1).clamp(widget.minScale, widget.maxScale);
    });
  }

  void _decreaseScale() {
    setState(() {
      scale = (scale - 0.1).clamp(widget.minScale, widget.maxScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double baseWidth = max(600, widget.width ?? screenSize.width);
    double baseHeight = widget.height ?? screenSize.height;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36,
              width: expanded ? baseWidth * scale : null,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: expanded
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).scaffoldBackgroundColor.withAlpha(60),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontFamily: "Bungee",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => expanded = !expanded),
                        icon: Icon(
                          expanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                      ),
                      if (expanded)
                        IconButton(
                          onPressed: _decreaseScale,
                          icon: const Icon(Icons.zoom_out, color: Colors.white),
                        ),
                      if (expanded)
                        IconButton(
                          onPressed: _increaseScale,
                          icon: const Icon(Icons.zoom_in, color: Colors.white),
                        ),
                      if (expanded)
                        if (widget.onPopup != null)
                          IconButton(
                            onPressed: () {
                              widget.onPopup!();
                            },
                            icon: const Icon(
                              Icons.outbond_outlined,
                              color: Colors.white,
                            ),
                          ),
                      if (expanded)
                        if (widget.onExit != null)
                          IconButton(
                            onPressed: () {
                              widget.onExit!();
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            // Corpo escalado (dentro do if)
            if (expanded)
              Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: baseWidth,
                    maxHeight: baseHeight,
                  ),
                  child: widget.child,
                ),
              ),

            // Header fixo no canto superior esquerdo
          ],
        ),
      ),
    );
  }
}
