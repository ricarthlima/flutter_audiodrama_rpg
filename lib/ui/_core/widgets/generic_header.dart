import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

class GenericHeader extends StatelessWidget {
  final String title;
  final IconButton? iconButton;

  const GenericHeader({
    super.key,
    required this.title,
    this.iconButton,
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
                  fontSize: 18,
                  fontFamily: FontFamily.bungee,
                ),
              ),
            ),
            if (iconButton != null) iconButton!
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(thickness: 0.1),
        ),
      ],
    );
  }
}
