import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

class GenericHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final IconButton? iconButton;
  final bool isSmallTitle;

  const GenericHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.iconButton,
    this.isSmallTitle = false,
    this.actions,
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
                fontSize: (!isSmallTitle) ? 18 : null,
                fontFamily: FontFamily.bungee,
              ),
            ),
            Row(
              children: [
                if (actions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                if (iconButton != null) iconButton!
              ],
            )
          ],
        ),
        if (subtitle != null)
          Opacity(
            opacity: 0.7,
            child: Text(
              subtitle!,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (!isSmallTitle)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 0.1),
          ),
      ],
    );
  }
}
