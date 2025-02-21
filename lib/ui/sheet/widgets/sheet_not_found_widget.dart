import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';

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
              GoRouter.of(context).go(AppRouter.home);
            },
            child: Text("Voltar"),
          ),
        ],
      ),
    );
  }
}
