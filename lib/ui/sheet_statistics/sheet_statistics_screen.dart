import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../_core/components/date_time_picker.dart';
import '../_core/dimensions.dart';
import 'view/statistics_view_model.dart';
import 'widgets/rolls_horizontal_bar.dart';
import 'widgets/rolls_ordered_list_widget.dart';

class SheetStatisticsScreen extends StatelessWidget {
  const SheetStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticsViewModel statisticsVM = context.watch<StatisticsViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      statisticsVM.onInitialize();
    });

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
                  controller: statisticsVM.startDateEditingController,
                  enabled: false,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDateTimePickerDialog(
                    context: context,
                    initialDate: statisticsVM.filterDateStart,
                    firstDate: statisticsVM.getFirstDate(),
                  ).then((DateTime? dateTimeResult) {
                    if (dateTimeResult != null) {
                      if (dateTimeResult.isAfter(statisticsVM.filterDateEnd)) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "A data inicial não pode ser depois da final",
                            ),
                          ),
                        );
                      } else {
                        statisticsVM.filterDateStart = dateTimeResult;
                      }
                    }
                  });
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
                  controller: statisticsVM.endDateEditingController,
                  enabled: false,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDateTimePickerDialog(
                    context: context,
                    initialDate: statisticsVM.filterDateEnd,
                    lastDate: DateTime.now(),
                  ).then((DateTime? dateTimeResult) {
                    if (dateTimeResult != null) {
                      statisticsVM.filterDateEnd = dateTimeResult;
                    }
                  });
                },
                icon: Icon(Icons.date_range),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: VerticalDivider(),
              ),
              TextButton(
                onPressed: () {
                  statisticsVM.resetDates();
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
