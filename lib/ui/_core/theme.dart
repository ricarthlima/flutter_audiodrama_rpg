import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

class AppTheme {
  AppTheme._();

  static const FloatingActionButtonThemeData _fabTD =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.red,
    foregroundColor: Colors.white,
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: FontFamily.sourceSerif4,
        ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.light,
    ),
    floatingActionButtonTheme: _fabTD,
    dividerTheme: DividerThemeData(
      color: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
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
    floatingActionButtonTheme: _fabTD,
    appBarTheme: AppBarTheme(elevation: 1, toolbarHeight: 64),
    dividerTheme: DividerThemeData(
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    ),
  );
}
