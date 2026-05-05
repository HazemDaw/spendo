import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    num amount, {
    required String symbol,
  }) {
    return NumberFormat.currency(
      locale: 'ru_RU',
      symbol: symbol,
      decimalDigits: 2,
    ).format(amount);
  }
}
