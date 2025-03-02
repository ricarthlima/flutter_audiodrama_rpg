import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/action_dao.dart';
import 'package:flutter_rpg_audiodrama/domain/models/action_template.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/app_colors.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/fonts.dart';
import 'package:provider/provider.dart';

import '../view/statistics_view_model.dart';

class RollsOrderedListWidget extends StatelessWidget {
  const RollsOrderedListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticsViewModel statisticsViewModel =
        Provider.of<StatisticsViewModel>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          statisticsViewModel.getListByCount().length,
          (index) {
            Map<String, int> map = statisticsViewModel.getListByCount()[index];
            ActionTemplate action =
                ActionDAO.instance.getActionById(map.keys.first)!;

            return ListTile(
              title: Text(
                action.name,
                style: TextStyle(
                    fontWeight: (index == 0) ? FontWeight.bold : null,
                    color: (index == 0) ? AppColors.red : null),
              ),
              trailing: Text(
                map.values.first.toString(),
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: FontFamily.bungee,
                    color: (index == 0) ? AppColors.red : null),
              ),
            );
          },
        ),
      ),
    );
  }
}
