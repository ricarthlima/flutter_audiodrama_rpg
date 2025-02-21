import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_keys.dart';

class LocalDataManager {
  Future<void> saveImageB64(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userImageB64, data);
  }
}
