import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(const Locale('ru')) {
    _loadLocale();
  }

  final SharedPreferences _prefs;
  static const String _key = 'app_locale';

  void _loadLocale() {
    final String? code = _prefs.getString(_key);
    if (code != null) {
      _setIntlDefault(Locale(code));
      emit(Locale(code));
      return;
    }
    _setIntlDefault(state);
  }

  void setLocale(Locale locale) {
    _prefs.setString(_key, locale.languageCode);
    _setIntlDefault(locale);
    emit(locale);
  }

  void toggleLocale() {
    if (state.languageCode == 'ru') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ru'));
    }
  }

  void _setIntlDefault(Locale locale) {
    Intl.defaultLocale = locale.languageCode == 'ru' ? 'ru_RU' : 'en_US';
  }
}
