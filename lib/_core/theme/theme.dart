import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/theme/app_colors.dart';
import 'package:flutter_rpg_audiodrama/_core/theme/fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData.light().copyWith(
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: FontFamily.sourceSerif4,
        ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.light,
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: FontFamily.sourceSerif4,
        ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.dark,
    ),
  );
}
