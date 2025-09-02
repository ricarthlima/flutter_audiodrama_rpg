import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/action_template.dart';
import '../../_core/app_colors.dart';
import '../../_core/fonts.dart';
import '../../sheet/providers/sheet_view_model.dart';

import '../view/statistics_view_model.dart';

class RollsOrderedListWidget extends StatelessWidget {
  const RollsOrderedListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticsViewModel statisticsViewModel = Provider.of<StatisticsViewModel>(
      context,
    );

    SheetViewModel sheetViewModel = Provider.of<SheetViewModel>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(statisticsViewModel.getListByCount().length, (
          index,
        ) {
          Map<String, int> map = statisticsViewModel.getListByCount()[index];
          ActionTemplate action = context
              .read<SheetViewModel>()
              .actionRepo
              .getActionById(map.keys.first)!;

          return ListTile(
            title: Text(
              action.name,
              style: TextStyle(
                fontWeight: (index == 0) ? FontWeight.bold : null,
                color: (index == 0) ? AppColors.red : null,
              ),
            ),
            subtitle: Text(sheetViewModel.getTrainLevelByActionName(action.id)),
            trailing: Text(
              map.values.first.toString(),
              style: TextStyle(
                fontSize: 24,
                fontFamily: FontFamily.bungee,
                color: (index == 0) ? AppColors.red : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
