import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyCubit extends Cubit<String> {
  CurrencyCubit(this._prefs) : super(defaultSymbol) {
    _loadCurrency();
  }

  static const String defaultSymbol = '₽';
  static const List<String> supportedSymbols = <String>['₽', r'$', '€'];
  static const String _key = 'currency_symbol';

  final SharedPreferences _prefs;

  void _loadCurrency() {
    final String? symbol = _prefs.getString(_key);
    if (symbol != null && supportedSymbols.contains(symbol)) {
      emit(symbol);
    }
  }

  void setCurrency(String symbol) {
    if (!supportedSymbols.contains(symbol) || symbol == state) {
      return;
    }

    _prefs.setString(_key, symbol);
    emit(symbol);
  }
}
