import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/providers/sheet_view_model.dart';

class SpellBondDialog extends StatelessWidget {
  final SheetViewModel sheetVM;
  const SpellBondDialog({super.key, required this.sheetVM});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          width: 2,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Text(
            (sheetVM.customCount("bond") != null)
                ? "Você está em um vínculo com '${sheetVM.customCount("bond")!.name}'"
                : "Você possui um vínculo mágico ativo",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.bungee,
              fontSize: 16,
              color: AppColors.red,
            ),
          ),
          Text(
            "Deseja desfazer e continuar?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Desistir"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text("Conjurar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
