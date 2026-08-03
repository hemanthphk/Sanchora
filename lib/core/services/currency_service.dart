import 'package:intl/intl.dart';

class CurrencyService {
  CurrencyService._internal();
  static final CurrencyService instance = CurrencyService._internal();

  String format(
    num amount, {
    String symbol = '₹',
    String locale = 'en_IN',
    int? decimalDigits,
    bool compact = false,
  }) {
    if (compact) {
      if (amount >= 1000 && amount < 1000000) {
        final double val = amount / 1000;
        final String numStr = val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1);
        return '$symbol${numStr}k';
      }
    }
    final bool isWhole = amount % 1 == 0;
    final int digits = decimalDigits ?? (isWhole ? 0 : 2);
    final NumberFormat formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: digits,
    );
    return formatter.format(amount);
  }
}
