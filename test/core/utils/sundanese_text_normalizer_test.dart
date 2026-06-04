import 'package:flutter_test/flutter_test.dart';
import 'package:fluxa_app/core/utils/sundanese_text_normalizer.dart';

void main() {
  group('SundaneseTextNormalizer', () {
    const normalizer = SundaneseTextNormalizer();

    test('normalizes Sundanese transaction words', () {
      final result = normalizer.normalize('mayar parkir motor lima rebu');

      expect(result, contains('bayar'));
      expect(result, contains('ribu'));
      expect(result, isNot(contains('mayar')));
      expect(result, isNot(contains('rebu')));
    });

    test('normalizes accented purchase and food phrases', () {
      final result = normalizer.normalize('  MÉSÉR   sangu goréng  ');

      expect(result, 'beli nasi goreng');
    });

    test('normalizes ojek online aliases', () {
      expect(normalizer.normalize('mayar ojék online'), 'bayar ojek online');
      expect(normalizer.normalize('mayar ojol'), 'bayar ojek online');
    });

    test('applies canonical wallet casing after normalization', () {
      final result = normalizer.normalize(
        'top up gopay tina bca terus dana ovo shopeepay cash mandiri bri',
      );

      expect(result, contains('GoPay'));
      expect(result, contains('BCA'));
      expect(result, contains('Dana'));
      expect(result, contains('OVO'));
      expect(result, contains('ShopeePay'));
      expect(result, contains('Cash'));
      expect(result, contains('Mandiri'));
      expect(result, contains('BRI'));
    });
  });
}
