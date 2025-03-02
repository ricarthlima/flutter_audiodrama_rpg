import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/_core/utils/roll_log_statistics.dart';
import 'package:flutter_rpg_audiodrama/domain/models/roll_log.dart';

class StatisticsViewModel extends ChangeNotifier {
  List<RollLog> listCompleteRollLog;
  StatisticsViewModel({required this.listCompleteRollLog});

  DateTime filterDateStart = DateTime.now().subtract(Duration(days: 1000));
  DateTime filterDateEnd = DateTime.now();

  Map<DateTime, Map<String, int>> get mapByDate {
    List<RollLog> listFiltered = RollLogStatistics.filterLogsByPeriod(
      listLogs: listCompleteRollLog,
      start: filterDateStart,
      end: filterDateEnd,
    );

    return RollLogStatistics.countActionsByDate(listFiltered);
  }

  List<BarChartGroupData> get listHorizontalBarGroup {
    return _prepareHorizontal(mapByDate);
  }

  List<BarChartGroupData> _prepareHorizontal(
      Map<DateTime, Map<String, int>> data) {
    List<BarChartGroupData> barGroups = [];
    int x = 0;
    data.forEach((date, actions) {
      List<BarChartRodData> barRods = [];
      actions.forEach((action, count) {
        barRods.add(BarChartRodData(
          toY: count.toDouble(),
          color: _getColorForAction(action), // Função para definir cor por ação
          width: 8,
        ));
      });
      barGroups.add(BarChartGroupData(
        x: x,
        barRods: barRods,
        barsSpace: 4,
      ));
      x++;
    });
    return barGroups;
  }

  Color _getColorForAction(String action) {
    // Defina cores específicas para cada ação
    switch (action) {
      case 'attack':
        return Colors.red;
      case 'defense':
        return Colors.blue;
      case 'spell_cast':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
