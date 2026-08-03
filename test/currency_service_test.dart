import 'package:flutter_test/flutter_test.dart';
import 'package:sanchora/core/services/currency_service.dart';

void main() {
  group('CurrencyService', () {
    test('formats integers with INR symbol and no decimal places by default', () {
      expect(CurrencyService.instance.format(2430), '₹2,430');
      expect(CurrencyService.instance.format(649), '₹649');
      expect(CurrencyService.instance.format(119), '₹119');
      expect(CurrencyService.instance.format(179), '₹179');
      expect(CurrencyService.instance.format(1250), '₹1,250');
      expect(CurrencyService.instance.format(720), '₹720');
      expect(CurrencyService.instance.format(280), '₹280');
    });

    test('formats doubles with INR symbol and 2 decimal places when fractional', () {
      expect(CurrencyService.instance.format(15.99), '₹15.99');
      expect(CurrencyService.instance.format(191.88), '₹191.88');
    });

    test('supports explicit decimalDigits', () {
      expect(CurrencyService.instance.format(139.00, decimalDigits: 2), '₹139.00');
      expect(CurrencyService.instance.format(20.00, decimalDigits: 2), '₹20.00');
    });

    test('supports custom symbol and locale for future localization', () {
      expect(CurrencyService.instance.format(1234.56, symbol: '\$', locale: 'en_US'), '\$1,234.56');
    });

    test('supports compact formatting', () {
      expect(CurrencyService.instance.format(2400, compact: true), '₹2.4k');
    });
  });
}
