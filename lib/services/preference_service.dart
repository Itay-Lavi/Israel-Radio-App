import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool?> getBoolPreference(String key) async {
    await _initPrefs();
    return _prefs!.getBool(key);
  }

  static Future<String?> getStringPreference(String key) async {
    await _initPrefs();
    return _prefs!.getString(key);
  }

  static Future<double?> getDoublePreference(String key) async {
    await _initPrefs();
    return _prefs!.getDouble(key);
  }

  static Future<int?> getIntPreference(String key) async {
    await _initPrefs();
    return _prefs!.getInt(key);
  }

  //Set Functions
  static Future<void> setBoolPreference(String key, bool value) async {
    await _initPrefs();
    await _prefs!.setBool(key, value);
  }

  static Future<void> setStringPreference(String key, String value) async {
    await _initPrefs();
    await _prefs!.setString(key, value);
  }

  static Future<void> setDoublePreference(String key, double value) async {
    await _initPrefs();
    await _prefs!.setDouble(key, value);
  }

  static Future<void> setIntPreference(String key, int value) async {
    await _initPrefs();
    await _prefs!.setInt(key, value);
  }
}
