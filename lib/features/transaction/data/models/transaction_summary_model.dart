import '../../domain/entities/transaction_summary_entity.dart';

class TransactionSummaryModel extends TransactionSummaryEntity {
  TransactionSummaryModel({
    required super.totalIncome,
    required super.totalExpense,
  }) : super(balance: totalIncome - totalExpense);

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    final totalIncome = _parseAmount(json['total_income']);
    final totalExpense = _parseAmount(json['total_expense']);
    return TransactionSummaryModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'balance': balance,
    };
  }

  TransactionSummaryEntity toEntity() {
    return TransactionSummaryEntity(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
