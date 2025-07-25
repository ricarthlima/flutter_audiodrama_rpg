import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/date_time_picker.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/view/statistics_view_model.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/widgets/rolls_horizontal_bar.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/widgets/rolls_ordered_list_widget.dart';
import 'package:provider/provider.dart';

import '../_core/dimensions.dart';

Future<void> showSheetStatisticsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(child: SheetStatisticsScreen());
    },
  );
}

class SheetStatisticsScreen extends StatelessWidget {
  const SheetStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticsViewModel statisticsViewModel =
        Provider.of<StatisticsViewModel>(context);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text("Data inicial: "),
              SizedBox(
                width: 150,
                child: TextFormField(
                  controller: statisticsViewModel.startDateEditingController,
                  enabled: false,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDateTimePickerDialog(
                    context: context,
                    initialDate: statisticsViewModel.filterDateStart,
                    firstDate: statisticsViewModel.getFirstDate(),
                  ).then(
                    (DateTime? dateTimeResult) {
                      if (dateTimeResult != null) {
                        if (dateTimeResult
                            .isAfter(statisticsViewModel.filterDateEnd)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "A data inicial não pode ser depois da final"),
                            ),
                          );
                        } else {
                          statisticsViewModel.filterDateStart = dateTimeResult;
                        }
                      }
                    },
                  );
                },
                icon: Icon(Icons.date_range),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: VerticalDivider(),
              ),
              Text("Data final: "),
              SizedBox(
                width: 150,
                child: TextFormField(
                  controller: statisticsViewModel.endDateEditingController,
                  enabled: false,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDateTimePickerDialog(
                    context: context,
                    initialDate: statisticsViewModel.filterDateEnd,
                    lastDate: DateTime.now(),
                  ).then(
                    (DateTime? dateTimeResult) {
                      if (dateTimeResult != null) {
                        statisticsViewModel.filterDateEnd = dateTimeResult;
                      }
                    },
                  );
                },
                icon: Icon(Icons.date_range),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: VerticalDivider(),
              ),
              TextButton(
                onPressed: () {
                  statisticsViewModel.resetDates();
                },
                child: Text("Redefinir"),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: (!isVertical(context)) ? 10 : 6,
                child: RollsHorizontalBar(),
              ),
              VerticalDivider(),
              Flexible(
                flex: (!isVertical(context)) ? 2 : 6,
                child: RollsOrderedListWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
