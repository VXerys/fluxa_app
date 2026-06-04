// ignore_for_file: avoid_print

/// Local Preprocessing Pipeline Evaluator
///
/// File dev-only ini mengevaluasi end-to-end flow preprocessing lokal:
///   raw_text
///     → normalizer.normalize()
///     → amountParser.parse()
///     → keywordMapper.detectType()
///     → validator.validateAndNormalize()
///
/// Jalankan dengan:
///   flutter test test/core/utils/local_preprocessing_pipeline_test.dart --reporter=expanded
///
/// Ini BUKAN mock Gemini. Ia memverifikasi bahwa local processing sudah
/// benar sebelum digabungkan dengan Gemini response di produksi.

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxa_app/core/utils/sundanese_text_normalizer.dart';
import 'package:fluxa_app/core/utils/amount_parser.dart';
import 'package:fluxa_app/core/utils/transaction_keyword_mapper.dart';
import 'package:fluxa_app/core/utils/voice_intent_json_validator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: menjalankan seluruh pipeline dan mencetak hasilnya ke console
// ─────────────────────────────────────────────────────────────────────────────

/// Representasi hasil dari pipeline preprocessing lokal.
class PipelineResult {
  const PipelineResult({
    required this.rawText,
    required this.normalizedText,
    required this.amount,
    required this.detectedType,
    required this.validated,
  });

  final String rawText;
  final String normalizedText;
  final double? amount;
  final String? detectedType;
  final Map<String, dynamic> validated;

  void printSummary() {
    print('─' * 60);
    print('  raw       : "$rawText"');
    print('  normalized: "$normalizedText"');
    print('  amount    : $amount');
    print('  type      : $detectedType');
    print('  validated : $validated');
    print('─' * 60);
  }
}

PipelineResult runPipeline(
  String rawText, {
  List<String> validCategories = const <String>[],
  List<String> validWallets = const <String>[],
}) {
  const normalizer = SundaneseTextNormalizer();
  const amountParser = AmountParser();
  const keywordMapper = TransactionKeywordMapper();
  const validator = VoiceIntentJsonValidator();

  // Step 1 – Normalize
  final normalizedText = normalizer.normalize(rawText);

  // Step 2 – Parse amount
  final amount = amountParser.parse(normalizedText);

  // Step 3 – Detect transaction type
  final detectedType = keywordMapper.detectType(normalizedText);

  // Step 4 – Build a synthetic JSON then validate/normalize it
  final syntheticJson = <String, dynamic>{
    'amount': amount,
    'type': detectedType,
    'category': null,
    'wallet': null,
    'note': normalizedText,
    'currency': 'IDR',
    'confidence': amount != null && detectedType != null ? 0.9 : 0.4,
  };

  final validated = validator.validateAndNormalize(
    json: syntheticJson,
    fallbackAmount: amount,
    validCategories: validCategories,
    validWallets: validWallets,
  );

  return PipelineResult(
    rawText: rawText,
    normalizedText: normalizedText,
    amount: amount,
    detectedType: detectedType,
    validated: validated,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Test cases
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('🔬 Local Preprocessing Pipeline — Evaluator', () {
    // ── Kasus dasar dari spesifikasi ──────────────────────────────────────────
    group('Contoh dari spesifikasi', () {
      test('mayar parkir motor lima rebu → expense 5000', () {
        final result = runPipeline('mayar parkir motor lima rebu');
        result.printSummary();

        expect(result.normalizedText, contains('bayar'),
            reason: '"mayar" harus dinormalisasi menjadi "bayar"');
        expect(result.normalizedText, contains('ribu'),
            reason: '"rebu" harus dinormalisasi menjadi "ribu"');
        expect(result.amount, 5000,
            reason: '"lima ribu" harus diparsing menjadi 5000');
        expect(result.detectedType, TransactionKeywordMapper.expense,
            reason: '"bayar" harus terdeteksi sebagai pengeluaran');

        // Validasi output akhir
        expect(result.validated['amount'], 5000.0);
        expect(result.validated['type'], 'expense');
        expect(result.validated['currency'], 'IDR');
      });
    });

    // ── Kasus pengeluaran (expense) ───────────────────────────────────────────
    group('Expense cases', () {
      test('beli kopi dua puluh ribu', () {
        final result = runPipeline('beli kopi dua puluh ribu');
        result.printSummary();

        expect(result.amount, 20000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('meser bensin lima belas ribu', () {
        final result = runPipeline('meser bensin lima belas ribu');
        result.printSummary();

        expect(result.normalizedText, contains('beli'));
        expect(result.amount, 15000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('jajan es teh delapan ribu', () {
        final result = runPipeline('jajan es teh delapan ribu');
        result.printSummary();

        expect(result.amount, 8000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('mayar makan siang dua puluh lima ribu', () {
        final result = runPipeline('mayar makan siang dua puluh lima ribu');
        result.printSummary();

        expect(result.normalizedText, contains('bayar'));
        expect(result.amount, 25000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('belanja bulanan satu juta dua ratus ribu', () {
        final result = runPipeline('belanja bulanan satu juta dua ratus ribu');
        result.printSummary();

        expect(result.amount, 1200000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('meuli sangu goreng lima belas rebu - Sundanese full', () {
        final result = runPipeline('meuli sangu goreng lima belas rebu');
        result.printSummary();

        expect(result.normalizedText, contains('beli'));
        expect(result.normalizedText, contains('nasi goreng'));
        expect(result.amount, 15000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });
    });

    // ── Kasus pemasukan (income) ──────────────────────────────────────────────
    group('Income cases', () {
      test('terima gaji dua juta', () {
        final result = runPipeline('nampi gajih dua juta');
        result.printSummary();

        expect(result.amount, 2000000);
        expect(result.detectedType, TransactionKeywordMapper.income);
      });

      test('dibayar proyek freelance tiga ratus ribu', () {
        final result = runPipeline('dibayar proyek freelance tiga ratus ribu');
        result.printSummary();

        expect(result.amount, 300000);
        expect(result.detectedType, TransactionKeywordMapper.income);
      });

      test('bonus akhir tahun lima ratus ribu', () {
        final result = runPipeline('bonus akhir tahun lima ratus ribu');
        result.printSummary();

        expect(result.amount, 500000);
        expect(result.detectedType, TransactionKeywordMapper.income);
      });
    });

    // ── Kasus transfer ────────────────────────────────────────────────────────
    group('Transfer cases', () {
      test('transfer ke BCA seratus ribu', () {
        final result = runPipeline(
          'transfer ke bca saratus ribu',
          validWallets: <String>['BCA', 'GoPay', 'Dana'],
        );
        result.printSummary();

        expect(result.normalizedText, contains('BCA'));
        expect(result.amount, 100000);
        expect(result.detectedType, TransactionKeywordMapper.transfer);
      });

      test('top up GoPay lima puluh ribu', () {
        final result = runPipeline(
          'top up gopay lima puluh ribu',
          validWallets: <String>['GoPay', 'OVO', 'Dana'],
        );
        result.printSummary();

        expect(result.normalizedText, contains('GoPay'));
        expect(result.amount, 50000);
        expect(result.detectedType, TransactionKeywordMapper.transfer);
      });

      test('kirim uang ke adik dua ratus ribu', () {
        final result = runPipeline('kirim uang ke adik dua ratus ribu');
        result.printSummary();

        expect(result.amount, 200000);
        expect(result.detectedType, TransactionKeywordMapper.transfer);
      });
    });

    // ── Kasus edge/negatif ────────────────────────────────────────────────────
    group('Edge & ambiguous cases', () {
      test('teks tanpa nominal → amount null', () {
        final result = runPipeline('beli kopi di warung');
        result.printSummary();

        expect(result.amount, isNull);
        expect(result.detectedType, TransactionKeywordMapper.expense);
        // Validator harus tetap mengembalikan map yang valid
        expect(result.validated.containsKey('amount'), isTrue);
        expect(result.validated['amount'], isNull);
      });

      test('teks tanpa keyword transaksi → type null', () {
        final result = runPipeline('kopi susu tiga ribu');
        result.printSummary();

        expect(result.amount, 3000);
        expect(result.detectedType, isNull);
        expect(result.validated['type'], isNull);
      });

      test('teks kosong sepenuhnya', () {
        final result = runPipeline('');
        result.printSummary();

        expect(result.normalizedText, '');
        expect(result.amount, isNull);
        expect(result.detectedType, isNull);
      });

      test('nominal numerik Rp langsung', () {
        final result = runPipeline('bayar listrik Rp150.000');
        result.printSummary();

        expect(result.amount, 150000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('nominal compact rb/k', () {
        final result = runPipeline('beli makan siang 35rb');
        result.printSummary();

        expect(result.amount, 35000);
        expect(result.detectedType, TransactionKeywordMapper.expense);
      });

      test('confidence rendah saat ambigu', () {
        final result = runPipeline('kopi susu tiga ribu');
        result.printSummary();

        // confidence hanya tinggi kalau type & amount keduanya terdeteksi
        expect(result.validated['confidence'], lessThan(0.9));
      });
    });

    // ── Snapshot test: output validated map lengkap ───────────────────────────
    group('Validated output structure', () {
      test('output map memiliki semua field wajib', () {
        final result = runPipeline('bayar ojol dua puluh ribu');
        result.printSummary();

        final validated = result.validated;
        expect(validated.containsKey('amount'), isTrue);
        expect(validated.containsKey('type'), isTrue);
        expect(validated.containsKey('category'), isTrue);
        expect(validated.containsKey('wallet'), isTrue);
        expect(validated.containsKey('note'), isTrue);
        expect(validated.containsKey('currency'), isTrue);
        expect(validated.containsKey('confidence'), isTrue);
      });

      test('currency selalu IDR (uppercase) meski tidak disebut', () {
        final result = runPipeline('jajan bakso dua belas ribu');
        expect(result.validated['currency'], 'IDR');
      });

      test('note berisi teks yang sudah dinormalisasi', () {
        final result = runPipeline('mayar parkir motor lima rebu');
        // note dari syntheticJson kita isi normalizedText
        expect(result.validated['note'], equals(result.normalizedText));
      });
    });
  });
}
