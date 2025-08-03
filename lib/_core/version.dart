import 'package:package_info_plus/package_info_plus.dart';

String _versionBook = "0.0.3 (behind)";

Future<String> get versionDev async {
  final info = await PackageInfo.fromPlatform();
  return 'version: ${info.version} - book: $_versionBook';
}
