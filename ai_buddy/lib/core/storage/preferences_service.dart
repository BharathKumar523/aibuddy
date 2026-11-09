import 'package:shared_preferences/shared_preferences.dart';

/// Keys for every non-sensitive preference the app stores.
///
/// `SharedPreferencesWithCache` only loads keys in [all], so new keys must
/// be added here.
abstract final class PreferenceKeys {
  static const String themeMode = 'theme_mode';

  static const Set<String> all = {themeMode};
}

/// Simple key-value preferences (theme, UI flags). Never store tokens here.
abstract interface class PreferencesService {
  String? getString(String key);
  Future<void> setString(String key, String value);
  bool? getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
}

/// [PreferencesService] backed by `SharedPreferencesWithCache`.
///
/// Values are loaded once at startup, so reads are synchronous. That lets
/// the theme be applied on the very first frame without a flash.
class SharedPreferencesService implements PreferencesService {
  SharedPreferencesService._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<SharedPreferencesService> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: PreferenceKeys.all,
      ),
    );
    return SharedPreferencesService._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Non-persistent fallback used in tests, and at startup if the platform
/// store fails to open, so the app still launches.
class InMemoryPreferencesService implements PreferencesService {
  InMemoryPreferencesService([Map<String, Object>? initialValues])
      : _values = <String, Object>{...?initialValues};

  final Map<String, Object> _values;

  @override
  String? getString(String key) {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  bool? getBool(String key) {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
