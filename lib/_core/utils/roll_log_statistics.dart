import '../../domain/models/roll_log.dart';

abstract class RollLogStatistics {
  static List<RollLog> filterLogsByPeriod({
    required List<RollLog> listLogs,
    required DateTime start,
    required DateTime end,
  }) {
    return listLogs.where((log) {
      return log.dateTime.isAfter(start) && log.dateTime.isBefore(end);
    }).toList();
  }

  static Map<String, int> countActions(List<RollLog> listLogs) {
    Map<String, int> count = {};
    for (RollLog log in listLogs) {
      count[log.idAction] = (count[log.idAction] ?? 0) + 1;
    }
    return count;
  }

  static Map<DateTime, Map<String, int>> countActionsByDate(
      List<RollLog> logs) {
    Map<DateTime, Map<String, int>> data = {};
    for (var log in logs) {
      DateTime date = log.dateTime;
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      if (!data.containsKey(dateOnly)) {
        data[dateOnly] = {};
      }
      data[dateOnly]![log.idAction] = (data[dateOnly]![log.idAction] ?? 0) + 1;
    }
    return data;
  }
}
