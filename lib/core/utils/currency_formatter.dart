import 'package:intl/intl.dart';

/// A reusable currency formatter utility for Sanchora.
///
/// Formats monetary values using the Indian Rupee (₹) by default.
/// Designed to be reusable for future localization and multiple currencies.
class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Formats a numeric [amount] into a localized currency string.
  ///
  /// - [symbol]: The currency symbol to use (defaults to '₹').
  /// - [locale]: The locale for number formatting (defaults to 'en_IN').
  /// - [decimalDigits]: Optional number of decimal places. If null, it defaults to
  ///   0 for integer amounts (or whole numbers) and 2 for fractional amounts.
  static String format(
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
    final int digits = isWhole ? 0 : (decimalDigits ?? 2);
    final NumberFormat formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: digits,
    );
    return formatter.format(amount);
  }
}
