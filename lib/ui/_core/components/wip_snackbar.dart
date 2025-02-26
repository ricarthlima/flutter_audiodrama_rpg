import 'package:flutter/material.dart';

showSnackBarWip(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Ainda não implementado. Fica pra próxima versão :)"),
      duration: Duration(milliseconds: 1200),
    ),
  );
}

showSnackBar({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 2000),
    ),
  );
}
