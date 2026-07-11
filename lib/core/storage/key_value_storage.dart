import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStorage {
  const KeyValueStorage(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<KeyValueStorage> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return KeyValueStorage(prefs);
  }

  String? getString(String key) => _prefs.getString(key);

  bool? getBool(String key) => _prefs.getBool(key);

  int? getInt(String key) => _prefs.getInt(key);

  double? getDouble(String key) => _prefs.getDouble(key);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  bool containsKey(String key) => _prefs.containsKey(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clear() => _prefs.clear();
}
