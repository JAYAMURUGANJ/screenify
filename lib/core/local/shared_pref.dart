//create a common shared preference class

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPref? _instance;
  static SharedPreferences? _prefs;

  SharedPref._();

  static Future<SharedPref> getInstance() async {
    if (_instance == null) {
      _instance = SharedPref._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
