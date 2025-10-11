import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

class TabTitle extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function()? onTap;
  final double fontSize;
  const TabTitle({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: FontFamily.bungee,
          fontSize: fontSize,
          color: isActive ? AppColors.red : AppColors.googleAuthBorderLight,
        ),
      ),
    );
  }
}
