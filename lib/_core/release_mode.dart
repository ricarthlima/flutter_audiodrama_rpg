import 'package:flutter/foundation.dart';

String get releaseCollection {
  if (kReleaseMode) {
    return "release-";
  }
  if (kDebugMode) {
    return "debug-";
  }
  return "profile-";
}
