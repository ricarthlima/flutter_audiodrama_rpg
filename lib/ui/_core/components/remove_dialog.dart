import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../fonts.dart';

Future<bool?> showRemoveSheetDialog({
  required BuildContext context,
  required String name,
}) {
  return showRemoveDialog(
    context: context,
    message: "Você tem certeza que deseja remover $name?",
  );
}

Future<bool?> showRemoveItemDialog({
  required BuildContext context,
  required String name,
  bool isOver = false,
}) {
  return showRemoveDialog(
    context: context,
    message: (isOver)
        ? "$name acabou. Deseja remover?"
        : "Você tem certeza que deseja remover $name?",
  );
}

Future<bool?> showRemoveDialog(
    {required BuildContext context, required String message}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: AppColors.red,
            ),
            color: Colors.black,
          ),
          padding: EdgeInsets.all(16),
          width: 375,
          height: 225,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ATENÇÃO",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: FontFamily.bungee,
                  color: Colors.white,
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                "Essa ação é irreversível",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Divider(color: Colors.white),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      "REMOVER",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: FontFamily.bungee,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
