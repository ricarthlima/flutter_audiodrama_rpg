import 'package:flutter/material.dart';

import '../fonts.dart';

class NamedWidget extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget child;
  final double? hardHeight;
  final bool isLeft;
  final bool isVisible;
  final String tooltip;

  final bool isShowRightSeparator;
  final bool isShowLeftSeparator;

  const NamedWidget({
    super.key,
    required this.title,
    this.titleWidget,
    required this.child,
    this.hardHeight,
    this.isLeft = false,
    this.isVisible = true,
    this.tooltip = "",
    this.isShowLeftSeparator = false,
    this.isShowRightSeparator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Tooltip(
        message: tooltip,
        child: Row(
          spacing: 8,
          children: [
            if (isShowLeftSeparator)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("•"),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: (isLeft)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                (titleWidget != null)
                    ? titleWidget!
                    : SizedBox(
                        height: 16,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: FontFamily.sourceSerif4,
                            fontSize: 10,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withAlpha(150),
                          ),
                        ),
                      ),
                (hardHeight != null)
                    ? SizedBox(height: hardHeight, child: child)
                    : child,
              ],
            ),
            if (isShowRightSeparator)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("•"),
              ),
          ],
        ),
      ),
    );
  }
}
