import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStorage {
  const KeyValueStorage(this._prefs);

  final SharedPreferencesWithCache _prefs;

  Future<void> clear() => _prefs.clear();

  bool containsKey(String key) => _prefs.containsKey(key);

  bool? getBool(String key) => _prefs.getBool(key);

  double? getDouble(String key) => _prefs.getDouble(key);

  int? getInt(String key) => _prefs.getInt(key);

  String? getString(String key) => _prefs.getString(key);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  static Future<KeyValueStorage> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const .new(),
    );
    return .new(prefs);
  }
}
