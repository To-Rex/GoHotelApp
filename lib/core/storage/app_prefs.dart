import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Oddiy (maxfiy bo'lmagan) sozlamalar: til, mavzu, qurilma ID, biometrika.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _kLocale = 'locale';
  static const _kTheme = 'theme_mode';
  static const _kDeviceId = 'device_id';
  static const _kBiometric = 'biometric_enabled';
  static const _kBiometricAsked = 'biometric_asked';
  static const _kLastUsername = 'last_username';

  // --- Til ------------------------------------------------------------------

  /// null — tizim tili (qo'llanmasa uz).
  Locale? get locale {
    final code = _prefs.getString(_kLocale);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }

  // --- Mavzu ----------------------------------------------------------------

  ThemeMode get themeMode {
    switch (_prefs.getString(_kTheme)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kTheme, mode.name);

  // --- Qurilma ID -----------------------------------------------------------

  /// Barqaror qurilma identifikatori — `X-Device-Id` sarlavhasi uchun.
  /// Administrator qurilmani shu ID bo'yicha tasdiqlaydi, shuning uchun u
  /// o'rnatishlar orasida o'zgarmasligi kerak.
  String get deviceId {
    var id = _prefs.getString(_kDeviceId);
    if (id == null || id.isEmpty) {
      id = _generateDeviceId();
      _prefs.setString(_kDeviceId, id);
    }
    return id;
  }

  static String _generateDeviceId() {
    final rnd = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final body = List.generate(
      24,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
    return 'mob-$body';
  }

  // --- Biometrika -----------------------------------------------------------

  bool get biometricEnabled => _prefs.getBool(_kBiometric) ?? false;

  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool(_kBiometric, value);

  /// Taklif faqat bir marta ko'rsatiladi — har login sayin bezovta qilmaymiz.
  bool get biometricAsked => _prefs.getBool(_kBiometricAsked) ?? false;

  Future<void> setBiometricAsked() => _prefs.setBool(_kBiometricAsked, true);

  // --- Oxirgi login ---------------------------------------------------------

  String? get lastUsername => _prefs.getString(_kLastUsername);

  Future<void> setLastUsername(String username) =>
      _prefs.setString(_kLastUsername, username);
}
