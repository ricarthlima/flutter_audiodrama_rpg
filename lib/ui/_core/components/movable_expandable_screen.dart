import 'package:flutter/material.dart';

class MovableExpandableScreen extends StatefulWidget {
  final Widget child;
  final String title;
  final double initialScale;
  final double minScale;
  final double maxScale;
  final Function? onPopup;
  final Function? onExit;

  const MovableExpandableScreen({
    super.key,
    required this.child,
    required this.title,
    this.initialScale = 0.5,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.onPopup,
    this.onExit,
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
    final screenSize = MediaQuery.of(context).size;
    final baseWidth = screenSize.width * 0.8;
    final baseHeight = screenSize.height * 0.8;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: Stack(
          children: [
            // Corpo escalado (dentro do if)
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 12,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenSize.width * 0.9,
                        maxHeight: screenSize.height * 0.9,
                      ),
                      child: SizedBox(
                        width: baseWidth,
                        height: baseHeight,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),

            // Header fixo no canto superior esquerdo
            Material(
              elevation: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              color: Colors.transparent,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: expanded
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).scaffoldBackgroundColor.withAlpha(60),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.title,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                    const SizedBox(width: 8),
                    IconButton(
                      iconSize: 16,
                      onPressed: () => setState(() => expanded = !expanded),
                      icon: Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      iconSize: 16,
                      onPressed: _increaseScale,
                      icon: const Icon(Icons.zoom_in, color: Colors.white),
                    ),
                    IconButton(
                      iconSize: 16,
                      onPressed: _decreaseScale,
                      icon: const Icon(Icons.zoom_out, color: Colors.white),
                    ),
                    if (widget.onPopup != null)
                      IconButton(
                        onPressed: () {
                          widget.onPopup!();
                        },
                        iconSize: 16,
                        icon: const Icon(
                          Icons.outbond_outlined,
                          color: Colors.white,
                        ),
                      ),
                    if (widget.onExit != null)
                      IconButton(
                        onPressed: () {
                          widget.onExit!();
                        },
                        iconSize: 16,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
