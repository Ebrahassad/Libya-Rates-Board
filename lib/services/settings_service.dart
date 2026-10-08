import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _languageKey = 'language_arabic';
  static const _baseKey = 'base_currency';
  static const _autoRefreshKey = 'auto_refresh';
  static const _intervalKey = 'refresh_interval_seconds';
  static const _stayAwakeKey = 'stay_awake';
  static const _fullScreenKey = 'full_screen';
  static const _tvModeKey = 'tv_mode';
  static const _soundKey = 'sound_on_change';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get arabic => _prefs?.getBool(_languageKey) ?? true;
  String get baseCurrency => _prefs?.getString(_baseKey) ?? 'LYD';
  bool get autoRefresh => _prefs?.getBool(_autoRefreshKey) ?? true;
  int get intervalSeconds => _prefs?.getInt(_intervalKey) ?? 300;
  bool get stayAwake => _prefs?.getBool(_stayAwakeKey) ?? true;
  bool get fullScreen => _prefs?.getBool(_fullScreenKey) ?? true;
  bool get tvMode => _prefs?.getBool(_tvModeKey) ?? false;
  bool get soundOnChange => _prefs?.getBool(_soundKey) ?? false;

  Future<void> setArabic(bool value) async {
    await _prefs?.setBool(_languageKey, value);
  }

  Future<void> setBaseCurrency(String value) async {
    await _prefs?.setString(_baseKey, value);
  }

  Future<void> setAutoRefresh(bool value) async {
    await _prefs?.setBool(_autoRefreshKey, value);
  }

  Future<void> setIntervalSeconds(int value) async {
    await _prefs?.setInt(_intervalKey, value);
  }

  Future<void> setStayAwake(bool value) async {
    await _prefs?.setBool(_stayAwakeKey, value);
  }

  Future<void> setFullScreen(bool value) async {
    await _prefs?.setBool(_fullScreenKey, value);
  }

  Future<void> setTvMode(bool value) async {
    await _prefs?.setBool(_tvModeKey, value);
  }

  Future<void> setSoundOnChange(bool value) async {
    await _prefs?.setBool(_soundKey, value);
  }
}
