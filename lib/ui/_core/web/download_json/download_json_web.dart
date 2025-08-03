import 'dart:convert';
import 'dart:html' as html;

void downloadJsonFile(Map<String, dynamic> data, String fileName) {
  final jsonString = jsonEncode(data);
  final blob = html.Blob([jsonString], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  // final anchor = html.AnchorElement(href: url)
  //   ..setAttribute("download", fileName)
  //   ..click();
  html.Url.revokeObjectUrl(url);
}
