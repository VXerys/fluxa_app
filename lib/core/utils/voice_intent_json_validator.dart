import 'transaction_keyword_mapper.dart';

class VoiceIntentJsonValidator {
  const VoiceIntentJsonValidator();

  Map<String, dynamic> validateAndNormalize({
    required Map<String, dynamic> json,
    double? fallbackAmount,
    List<String> validCategories = const <String>[],
    List<String> validWallets = const <String>[],
  }) {
    return <String, dynamic>{
      'amount': _sanitizeAmount(json['amount'], fallbackAmount),
      'type': _sanitizeType(json['type']),
      'category': _sanitizeKnownValue(json['category'], validCategories),
      'wallet': _sanitizeKnownValue(json['wallet'], validWallets),
      'note': _sanitizeNote(json['note']),
      'currency': _sanitizeCurrency(json['currency']),
      'confidence': _sanitizeConfidence(json['confidence']),
    };
  }

  double? _sanitizeAmount(dynamic value, double? fallbackAmount) {
    if (value is num) {
      final amount = value.toDouble();
      if (amount.isFinite) return amount;
    }

    return fallbackAmount;
  }

  String? _sanitizeType(dynamic value) {
    if (value is! String) return null;

    final type = value.trim().toLowerCase();
    if (type == TransactionKeywordMapper.income ||
        type == TransactionKeywordMapper.expense ||
        type == TransactionKeywordMapper.transfer) {
      return type;
    }

    return null;
  }

  String? _sanitizeKnownValue(dynamic value, List<String> validValues) {
    if (value is! String || validValues.isEmpty) return null;

    final normalizedValue = value.trim().toLowerCase();
    if (normalizedValue.isEmpty) return null;

    for (final validValue in validValues) {
      if (validValue.trim().toLowerCase() == normalizedValue) {
        return validValue;
      }
    }

    return null;
  }

  String? _sanitizeNote(dynamic value) {
    if (value is! String) return null;

    final note = value.trim();
    return note.isEmpty ? null : note;
  }

  String _sanitizeCurrency(dynamic value) {
    if (value is String) {
      final currency = value.trim();
      if (currency.isNotEmpty) {
        return currency.toUpperCase();
      }
    }

    return 'IDR';
  }

  double _sanitizeConfidence(dynamic value) {
    if (value is! num) return 0.0;

    final confidence = value.toDouble();
    if (!confidence.isFinite) return 0.0;
    if (confidence < 0.0) return 0.0;
    if (confidence > 1.0) return 1.0;

    return confidence;
  }
}
