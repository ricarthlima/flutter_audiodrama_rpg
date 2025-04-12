// ignore_for_file: unused_local_variable, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

void downloadJsonFile(Map<String, dynamic> data, String fileName) {
  final jsonString = jsonEncode(data);
  final blob = html.Blob([jsonString], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
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
