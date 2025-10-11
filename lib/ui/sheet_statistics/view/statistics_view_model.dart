import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../_core/utils/roll_log_statistics.dart';
import '../../../domain/models/roll_log.dart';
import '../../sheet/providers/sheet_view_model.dart';

class StatisticsViewModel extends ChangeNotifier {
  final SheetViewModel sheetVM;
  StatisticsViewModel({required this.sheetVM});

  void onInitialize() {
    listCompleteRollLog = sheetVM.sheet!.listRollLog;
    notifyListeners();
  }

  List<RollLog> _listCompleteRollLog = [];
  List<RollLog> get listCompleteRollLog => _listCompleteRollLog;
  set listCompleteRollLog(List<RollLog> listValues) {
    _listCompleteRollLog = listValues;
    _filterDateStart = getFirstDate();
    notifyListeners();
  }

  DateTime _filterDateStart = DateTime.now().subtract(Duration(days: 365));
  DateTime get filterDateStart => _filterDateStart;
  set filterDateStart(DateTime datetime) {
    _filterDateStart = datetime;
    notifyListeners();
  }

  DateTime _filterDateEnd = DateTime.now();
  DateTime get filterDateEnd => _filterDateEnd;
  set filterDateEnd(DateTime datetime) {
    _filterDateEnd = datetime;
    notifyListeners();
  }

  Map<DateTime, Map<String, int>> get mapByDate {
    List<RollLog> listFiltered = RollLogStatistics.filterLogsByPeriod(
      listLogs: listCompleteRollLog,
      start: _filterDateStart,
      end: _filterDateEnd,
    );

    return RollLogStatistics.countActionsByDate(listFiltered);
  }

  List<Map<String, int>> getListByCount() {
    List<Map<String, int>> listResult =
        RollLogStatistics.countActions(
          RollLogStatistics.filterLogsByPeriod(
            listLogs: listCompleteRollLog,
            start: _filterDateStart,
            end: _filterDateEnd,
          ),
        ).entries.map((entry) {
          return {entry.key: entry.value};
        }).toList();

    listResult.sort((a, b) => b.values.first.compareTo(a.values.first));

    return listResult;
  }

  List<BarChartGroupData> get listHorizontalBarGroup {
    return _prepareHorizontal(mapByDate);
  }

  List<BarChartGroupData> _prepareHorizontal(
    Map<DateTime, Map<String, int>> data,
  ) {
    List<BarChartGroupData> barGroups = [];
    int x = 0;
    data.forEach((date, actions) {
      List<BarChartRodData> barRods = [];
      actions.forEach((action, count) {
        barRods.add(BarChartRodData(toY: count.toDouble(), width: 8));
      });
      barGroups.add(BarChartGroupData(x: x, barRods: barRods, barsSpace: 4));
      x++;
    });
    return barGroups;
  }

  final TextEditingController _startDateEditingController =
      TextEditingController();

  TextEditingController get startDateEditingController {
    _startDateEditingController.text = DateFormat(
      "dd/MM/yyyy HH:mm",
    ).format(_filterDateStart);

    return _startDateEditingController;
  }

  final TextEditingController _endDateEditingController =
      TextEditingController();

  TextEditingController get endDateEditingController {
    _endDateEditingController.text = DateFormat(
      "dd/MM/yyyy HH:mm",
    ).format(_filterDateEnd);

    return _endDateEditingController;
  }

  DateTime getFirstDate() {
    DateTime dateTime = listCompleteRollLog
        .reduce(
          (value, element) =>
              element.dateTime.isBefore(value.dateTime) ? element : value,
        )
        .dateTime;
    return dateTime;
  }

  void resetDates() {
    _filterDateStart = getFirstDate();
    _filterDateEnd = DateTime.now();
    notifyListeners();
  }

  void defineOneDay(DateTime date) {
    _filterDateStart = date.copyWith(hour: 0, minute: 0, second: 0);
    _filterDateEnd = date.copyWith(hour: 23, minute: 59, second: 59);
    notifyListeners();
  }
}
