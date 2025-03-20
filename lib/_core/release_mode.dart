import 'package:flutter/foundation.dart';

String get releaseCollection {
  // return "release-";
  if (kReleaseMode) {
    return "release-";
  }
  if (kDebugMode) {
    return "debug-";
  }
  return "profile-";
}
