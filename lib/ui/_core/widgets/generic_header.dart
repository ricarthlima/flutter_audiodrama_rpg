import 'package:flutter/material.dart';

import '../fonts.dart';

class GenericHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final List<Widget>? actions;
  final Widget? iconButton;
  final bool dense;
  final bool showDivider;

  const GenericHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.iconButton,
    this.dense = false,
    this.actions,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: (!dense) ? 18 : null,
                fontFamily: FontFamily.bungee,
              ),
            ),
            SizedBox(
              height: 38,
              child: Row(
                children: [
                  if (actions != null)
                    Row(mainAxisSize: MainAxisSize.min, children: actions!),
                  if (iconButton != null) iconButton!,
                ],
              ),
            ),
          ],
        ),
        if (subtitle != null)
          Opacity(
            opacity: 0.7,
            child: Text(
              subtitle!,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        if (subtitleWidget != null) subtitleWidget!,
        if (!dense && showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 0.1),
          ),
      ],
    );
  }
}
