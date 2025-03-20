import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_keys.dart';

class LocalDataManager {
  LocalDataManager._();
  static final LocalDataManager _instance = LocalDataManager._();
  static LocalDataManager get instance => _instance;

  static const String _keyListAchievements = "LIST_ACHIEVEMENTS";

  Future<void> saveImageB64(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userImageB64, data);
  }

  Future<List<String>> getAchievementsListIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_keyListAchievements)) ?? [];
  }

  Future<void> addAchievement(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listIds = await getAchievementsListIds();
    listIds.add(id);
    prefs.setStringList(_keyListAchievements, listIds);
  }
}
