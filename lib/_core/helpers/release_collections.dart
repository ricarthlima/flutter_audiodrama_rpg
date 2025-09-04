String get rc {
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  if (flavor != 'dev') {
    return "release-";
  }
  return "";
}
