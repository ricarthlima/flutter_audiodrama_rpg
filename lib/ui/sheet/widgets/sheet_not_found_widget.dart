import 'package:flutter/material.dart';
import '../../../router.dart';

class SheetNotFoundWidget extends StatelessWidget {
  const SheetNotFoundWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text("Ficha não encontrada"),
          ElevatedButton(
            onPressed: () {
              AppRouter().goHome(context: context);
            },
            child: Text("Voltar"),
          ),
        ],
      ),
    );
  }
}
