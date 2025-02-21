import 'package:flutter/material.dart';

showSnackBarWip(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Ainda não implementado. Fica pra próxima versão :)"),
      duration: Duration(milliseconds: 1200),
    ),
  );
}
