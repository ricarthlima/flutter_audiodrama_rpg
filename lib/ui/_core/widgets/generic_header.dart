import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

class GenericHeader extends StatelessWidget {
  final String title;
  final IconButton? iconButton;
  final bool isSmallTitle;

  const GenericHeader({
    super.key,
    required this.title,
    this.iconButton,
    this.isSmallTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: (!isSmallTitle) ? 18 : null,
                  fontFamily: FontFamily.bungee,
                ),
              ),
            ),
            if (iconButton != null) iconButton!
          ],
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
