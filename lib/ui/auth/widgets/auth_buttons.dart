import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';

class GoogleAuthButtonWidget extends StatelessWidget {
  final Function onPressed;
  final ThemeMode themeMode;
  const GoogleAuthButtonWidget({
    super.key,
    required this.onPressed,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          color: (themeMode == ThemeMode.light)
              ? AppColors.googleAuthFillLight
              : AppColors.googleAuthFillDark,
          border: Border.all(
            color: (themeMode == ThemeMode.light)
                ? AppColors.googleAuthBorderLight
                : AppColors.googleAuthBorderDark,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/g.png",
              width: 22,
            ),
            SizedBox(width: 10),
            Text(
              "Continuar com o Google",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: (themeMode == ThemeMode.light)
                    ? AppColors.googleAuthTextLight
                    : AppColors.googleAuthTextDark,
                fontFamily: "Roboto",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
