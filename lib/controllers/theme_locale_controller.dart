import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ThemeLocaleController extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('zh', 'TW');

  ThemeLocaleController(this._prefs) {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void _loadPreferences() {
    final themeStr = _prefs.getString(AppConstants.prefKeyThemeMode);
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    final localeStr = _prefs.getString(AppConstants.prefKeyLocale);
    if (localeStr != null) {
      if (localeStr == 'en_US' || localeStr == 'en') {
        _locale = const Locale('en', 'US');
      } else if (localeStr == 'ja_JP' || localeStr == 'ja') {
        _locale = const Locale('ja', 'JP');
      } else if (localeStr == 'zh_CN') {
        _locale = const Locale('zh', 'CN');
      } else {
        _locale = const Locale('zh', 'TW');
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    await _prefs.setString(AppConstants.prefKeyThemeMode, modeStr);
    notifyListeners();
  }

  Future<void> setLocale(Locale loc) async {
    _locale = loc;
    final locStr = loc.countryCode != null ? '${loc.languageCode}_${loc.countryCode}' : loc.languageCode;
    await _prefs.setString(AppConstants.prefKeyLocale, locStr);
    notifyListeners();
  }
}
