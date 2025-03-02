import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/widgets/rolls_horizontal_bar.dart';

import '../_core/dimensions.dart';

Future<void> showSheetStatisticsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(child: StatisticsScreen());
    },
  );
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Estatísticas")),
      body: Container(
        width: width(context),
        height: height(context),
        padding: EdgeInsets.all(16),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(tabs: [
                Tab(text: "Linha do Tempo"),
                Tab(text: "Anotações"),
              ]),
              Expanded(
                child: TabBarView(
                  children: [
                    RollsHorizontalBar(),
                    Placeholder(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
