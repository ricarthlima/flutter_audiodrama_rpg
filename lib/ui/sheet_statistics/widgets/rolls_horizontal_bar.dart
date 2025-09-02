import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../sheet/providers/sheet_view_model.dart';
import '../view/statistics_view_model.dart';

class RollsHorizontalBar extends StatelessWidget {
  const RollsHorizontalBar({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticsViewModel statisticsViewModel = Provider.of<StatisticsViewModel>(
      context,
    );
    return BarChart(
      BarChartData(
        barGroups: statisticsViewModel.listHorizontalBarGroup,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: Text("Quantidade de rolagens por ação"),
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text("Data das Rolagens"),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index < statisticsViewModel.mapByDate.keys.length) {
                  DateTime date = statisticsViewModel.mapByDate.keys.elementAt(
                    index,
                  );
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
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // Pegamos a data associada ao grupo atual
              DateTime date = statisticsViewModel.mapByDate.keys.elementAt(
                group.x,
              );

              // Pegamos a ação correspondente dentro do grupo
              String? idAction;
              if (group.barRods.length > rodIndex) {
                idAction = statisticsViewModel.mapByDate[date]?.keys.elementAt(
                  rodIndex,
                );
              }

              if (idAction != null) {
                idAction = context
                    .read<SheetViewModel>()
                    .actionRepo
                    .getActionById(idAction)!
                    .name;
              }

              return BarTooltipItem(
                idAction != null
                    ? "$idAction (${rod.toY.toInt()})"
                    : "Desconhecido (${rod.toY.toInt()})",
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }
}
