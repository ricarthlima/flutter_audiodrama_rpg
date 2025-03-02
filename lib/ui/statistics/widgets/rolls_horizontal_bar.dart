import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/statistics/view/statistics_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RollsHorizontalBar extends StatelessWidget {
  const RollsHorizontalBar({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticsViewModel statisticsViewModel =
        Provider.of<StatisticsViewModel>(context);
    return BarChart(
      BarChartData(
        barGroups: statisticsViewModel.listHorizontalBarGroup,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index < statisticsViewModel.mapByDate.keys.length) {
                  DateTime date =
                      statisticsViewModel.mapByDate.keys.elementAt(index);
                  return SideTitleWidget(
                    // axisSide: meta.axisSide,
                    meta: meta,
                    child: InkWell(
                      onTap: () {
                        statisticsViewModel.defineOneDay(date);
                      },
                      child: Text(
                        DateFormat('dd/MM').format(date),
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        groupsSpace: 12,
      ),
    );
  }
}
