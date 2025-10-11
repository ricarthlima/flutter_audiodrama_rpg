import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'fonts.dart';

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
    dividerTheme: DividerThemeData(color: Colors.black),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: OutlineInputBorder(borderRadius: BorderRadius.zero),
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
    scaffoldBackgroundColor: AppColors.backgroundDark,
    floatingActionButtonTheme: _fabTD,
    appBarTheme: AppBarTheme(
      elevation: 1,
      toolbarHeight: 64,
      backgroundColor: AppColors.googleAuthFillDark,
    ),
    dividerTheme: DividerThemeData(color: Colors.white, thickness: 0.33),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: FontFamily.sourceSerif4,
      ),
      shape: OutlineInputBorder(borderRadius: BorderRadius.zero),
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: Radius.zero,
      thickness: WidgetStatePropertyAll(6),
    ),
  );
}
