import 'package:flutter/material.dart';

Future<String?> showCreateSheetDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      TextEditingController nameController = TextEditingController();
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 10,
        title: Text(
          "Aqui começa uma história",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            label: Text("Nome"),
          ),
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
