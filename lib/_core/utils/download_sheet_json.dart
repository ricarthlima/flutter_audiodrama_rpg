import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../../domain/models/sheet_model.dart';
import '../../ui/_core/web/download_json/download_json.dart';
import '../../ui/sheet/providers/sheet_view_model.dart';

Future<void> downloadSheetJSON(SheetViewModel sheetVM) async {
  Sheet? sheet = await sheetVM.saveChanges();

  if (sheet != null) {
    downloadJsonFile(
      sheet.toMapWithoutId(),
      "sheet-${sheet.characterName.toLowerCase().replaceAll(" ", "_")}.json",
    );
  }
}

Future<Map<String, dynamic>?> pickAndReadJsonFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null && result.files.single.bytes != null) {
    final bytes = result.files.single.bytes!;
    final jsonString = utf8.decode(bytes);
    final jsonData = jsonDecode(jsonString);
    return jsonData;
  }
  return null;
}
