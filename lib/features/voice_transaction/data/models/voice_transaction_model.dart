import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/voice_transaction_entity.dart';

class VoiceTransactionModel extends VoiceTransactionEntity {
  const VoiceTransactionModel({
    required super.type,
    required super.amount,
    required super.category,
    super.wallet,
    super.title,
    super.description,
    required super.currency,
    super.date,
  });

  factory VoiceTransactionModel.fromJson(Map<String, dynamic> json) {
    return VoiceTransactionModel(
      type: json['type'] as String? ?? 'expense',
      amount: _parseDouble(json['amount']),
      category: json['category'] as String? ?? '',
      wallet: json['wallet'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      currency: json['currency'] as String? ?? AppConstants.defaultCurrency,
      date: json['date'] as String?,
    );
  }

  VoiceTransactionEntity toEntity() {
    return VoiceTransactionEntity(
      type: type,
      amount: amount,
      category: category,
      wallet: wallet,
      title: title,
      description: description,
      currency: currency,
      date: date,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

