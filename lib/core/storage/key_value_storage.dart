import 'package:shared_preferences/shared_preferences.dart';

final class KeyValueStorage {
  const KeyValueStorage(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  bool? getBool(String key) => _prefs.getBool(key);

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
