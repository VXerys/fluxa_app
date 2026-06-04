import 'package:flutter_test/flutter_test.dart';
import 'package:fluxa_app/core/utils/transaction_keyword_mapper.dart';
import 'package:fluxa_app/core/utils/voice_intent_json_validator.dart';

void main() {
  group('VoiceIntentJsonValidator', () {
    const validator = VoiceIntentJsonValidator();

    test('sanitizes valid parser JSON', () {
      final result = validator.validateAndNormalize(
        json: <String, dynamic>{
          'amount': 15000,
          'type': 'expense',
          'category': 'Kopi',
          'wallet': 'gopay',
          'note': '  Kopi pagi  ',
          'currency': 'idr',
          'confidence': 0.75,
        },
        validCategories: const <String>['Kopi', 'Transport'],
        validWallets: const <String>['GoPay', 'BCA'],
      );

      expect(result['amount'], 15000.0);
      expect(result['type'], TransactionKeywordMapper.expense);
      expect(result['category'], 'Kopi');
      expect(result['wallet'], 'GoPay');
      expect(result['note'], 'Kopi pagi');
      expect(result['currency'], 'IDR');
      expect(result['confidence'], 0.75);
    });

    test('uses fallback amount when AI amount is null', () {
      final result = validator.validateAndNormalize(
        json: <String, dynamic>{'amount': null},
        fallbackAmount: 5000,
      );

      expect(result['amount'], 5000.0);
    });

    test('sets invalid category and wallet to null', () {
      final result = validator.validateAndNormalize(
        json: <String, dynamic>{
          'category': 'Tidak Ada',
          'wallet': 'Unknown Wallet',
        },
        validCategories: const <String>['Makanan'],
        validWallets: const <String>['Cash'],
      );

      expect(result['category'], isNull);
      expect(result['wallet'], isNull);
    });

    test('sets category and wallet to null when valid lists are empty', () {
      final result = validator.validateAndNormalize(
        json: <String, dynamic>{
          'category': 'Makanan',
          'wallet': 'Cash',
        },
      );

      expect(result['category'], isNull);
      expect(result['wallet'], isNull);
    });

    test('normalizes invalid type, empty note, currency, and confidence', () {
      final result = validator.validateAndNormalize(
        json: <String, dynamic>{
          'type': 'other',
          'note': '   ',
          'currency': '',
          'confidence': 2.4,
        },
      );

      expect(result['type'], isNull);
      expect(result['note'], isNull);
      expect(result['currency'], 'IDR');
      expect(result['confidence'], 1.0);
    });

    test('defaults invalid confidence to zero', () {
      final result = validator.validateAndNormalize(
        json: <String, dynamic>{'confidence': 'high'},
      );

      expect(result['confidence'], 0.0);
    });
  });
}
