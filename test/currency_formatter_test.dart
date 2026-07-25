import 'package:flutter_test/flutter_test.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats integers with INR symbol and no decimal places by default', () {
      expect(CurrencyFormatter.format(2430), '₹2,430');
      expect(CurrencyFormatter.format(649), '₹649');
      expect(CurrencyFormatter.format(119), '₹119');
      expect(CurrencyFormatter.format(179), '₹179');
      expect(CurrencyFormatter.format(1250), '₹1,250');
      expect(CurrencyFormatter.format(720), '₹720');
      expect(CurrencyFormatter.format(280), '₹280');
    });

    test('formats doubles with INR symbol and 2 decimal places when fractional', () {
      expect(CurrencyFormatter.format(15.99), '₹15.99');
      expect(CurrencyFormatter.format(191.88), '₹191.88');
    });

    test('supports explicit decimalDigits', () {
      expect(CurrencyFormatter.format(139.00, decimalDigits: 2), '₹139.00');
      expect(CurrencyFormatter.format(20.00, decimalDigits: 2), '₹20.00');
    });

    test('supports custom symbol and locale for future localization', () {
      expect(CurrencyFormatter.format(1234.56, symbol: '\$', locale: 'en_US'), '\$1,234.56');
    });

    test('supports compact formatting', () {
      expect(CurrencyFormatter.format(2400, compact: true), '₹2.4k');
    });
  });
}
