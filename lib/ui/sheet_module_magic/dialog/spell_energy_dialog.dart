import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';

class SpellEnergyDialog extends StatefulWidget {
  final int minEnergy;
  const SpellEnergyDialog({super.key, required this.minEnergy});

  @override
  State<SpellEnergyDialog> createState() => _SpellEnergyDialogState();
}

class _SpellEnergyDialogState extends State<SpellEnergyDialog> {
  int energy = 0;

  @override
  void initState() {
    energy = widget.minEnergy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: 128,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            "Quanto de energia?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: FontFamily.bungee),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: (energy == widget.minEnergy)
                    ? null
                    : () {
                        setState(() {
                          energy--;
                        });
                      },
                icon: Icon(Icons.remove),
              ),
              Text(
                energy.toString(),
                style: TextStyle(fontSize: 32, fontFamily: FontFamily.bungee),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    energy++;
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, energy);
            },
            child: Text("Rolar"),
          ),
        ],
      ),
    );
  }
}
