import 'package:flutter_test/flutter_test.dart';
import 'package:fluxa_app/core/utils/amount_parser.dart';

void main() {
  group('AmountParser', () {
    const parser = AmountParser();

    test('prefers numeric rupiah amount', () {
      expect(parser.parse('mésér kopi Rp15.000 lima rebu'), 15000);
    });

    test('parses compact numeric suffixes', () {
      expect(parser.parse('beli kopi 15rb'), 15000);
      expect(parser.parse('beli kopi 15k'), 15000);
    });

    test('parses simple word amounts', () {
      expect(parser.parse('jajan lima ribu'), 5000);
      expect(parser.parse('jajan lima rebu'), 5000);
    });

    test('parses belas and accented rebu', () {
      expect(parser.parse('mésér kopi lima belas rébu'), 15000);
    });

    test('parses puluh ribu', () {
      expect(parser.parse('parkir tujuh puluh lima ribu'), 75000);
    });

    test('parses juta and ribu composition', () {
      expect(parser.parse('gajih dua juta'), 2000000);
      expect(parser.parse('gajih dua juta lima ratus ribu'), 2500000);
    });

    test('parses Sundanese special hundreds and thousands', () {
      expect(parser.parse('saratus ribu'), 100000);
      expect(parser.parse('sarébu'), 1000);
      expect(parser.parse('sarebu'), 1000);
    });

    test('returns null when no amount can be parsed', () {
      expect(parser.parse('beli kopi di warung'), isNull);
    });
  });
}
