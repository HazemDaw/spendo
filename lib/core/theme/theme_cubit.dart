import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.light) {
    _loadTheme();
  }

  final SharedPreferences _prefs;
  static const String _key = 'dark_mode';

  void _loadTheme() {
    final bool isDark = _prefs.getBool(_key) ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final bool isDark = state == ThemeMode.dark;
    _prefs.setBool(_key, !isDark);
    emit(!isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
