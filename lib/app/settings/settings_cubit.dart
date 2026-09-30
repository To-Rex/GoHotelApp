import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/app_prefs.dart';

/// Til va mavzu — butun ilova bo'ylab.
class SettingsState extends Equatable {
  const SettingsState({required this.themeMode, this.locale});

  final ThemeMode themeMode;

  /// null — tizim tili.
  final Locale? locale;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    locale: clearLocale ? null : (locale ?? this.locale),
  );

  @override
  List<Object?> get props => [themeMode, locale];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs)
    : super(SettingsState(themeMode: _prefs.themeMode, locale: _prefs.locale));

  final AppPrefs _prefs;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(Locale? locale) async {
    await _prefs.setLocale(locale);
    emit(state.copyWith(locale: locale, clearLocale: locale == null));
  }
}
