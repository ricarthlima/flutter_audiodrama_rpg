import 'package:flutter/material.dart';

Future<dynamic> showCreateSheetDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      TextEditingController nameController = TextEditingController();
      return AlertDialog(
        title: Text("Qual o nome?"),
        content: TextFormField(
          controller: nameController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                nameController.text,
              );
            },
            child: Text("Criar"),
          ),
        ],
      );
    },
  );
}
