import 'package:flutter_test/flutter_test.dart';
import 'package:fluxa_app/core/utils/transaction_keyword_mapper.dart';

void main() {
  group('TransactionKeywordMapper', () {
    const mapper = TransactionKeywordMapper();

    test('detects income keywords', () {
      expect(
        mapper.detectType('gajih dua juta lima ratus ribu'),
        TransactionKeywordMapper.income,
      );
      expect(mapper.detectType('nampi bonus'), TransactionKeywordMapper.income);
    });

    test('detects expense keywords', () {
      expect(mapper.detectType('bayar parkir'), TransactionKeywordMapper.expense);
      expect(mapper.detectType('beli kopi'), TransactionKeywordMapper.expense);
    });

    test('detects transfer with highest priority', () {
      expect(
        mapper.detectType('top up gopay lima puluh ribu'),
        TransactionKeywordMapper.transfer,
      );
      expect(
        mapper.detectType('transfer bayar tagihan'),
        TransactionKeywordMapper.transfer,
      );
    });

    test('returns null when no keyword exists', () {
      expect(mapper.detectType('catetan tanpa arah transaksi'), isNull);
    });
  });
}
