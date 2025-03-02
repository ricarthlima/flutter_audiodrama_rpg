import 'package:flutter/material.dart';

Future<DateTime?> showDateTimePickerDialog({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2100),
    locale: const Locale('pt', 'BR'),
  );

  if (pickedDate != null) {
    if (!context.mounted) return null;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime != null) {
      DateTime finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      return finalDateTime;
    }
  }
  return null;
}
