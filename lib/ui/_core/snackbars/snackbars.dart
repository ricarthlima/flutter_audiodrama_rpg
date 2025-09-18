import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';

void showImageTooLargeSnackbar(BuildContext context) {
  _showErrorSnackBar(context, "Sua imagem é pesada demais.");
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: AppColors.red,
      showCloseIcon: true,
    ),
  );
}
