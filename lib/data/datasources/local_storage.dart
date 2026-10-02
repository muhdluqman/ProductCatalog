import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for app-local persistence.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  List<String> getStringList(String key) {
    return _prefs.getStringList(key) ?? const [];
  }

  Future<void> setStringList(String key, List<String> values) {
    return _prefs.setStringList(key, values);
  }

  Future<void> remove(String key) {
    return _prefs.remove(key);
  }
}
