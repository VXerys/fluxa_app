import 'category_entity.dart';

class TransactionEntity {
  final String id;
  final String userId;
  final String? categoryId;
  final String? walletId;
  final String? walletName;
  final String? walletType;
  final String? walletCurrency;
  final String type;
  final double amount;
  final String currency;
  final String? note;
  final DateTime date;
  final String? time;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CategoryEntity? category;

  TransactionEntity({
    required this.id,
    required this.userId,
    this.categoryId,
    this.walletId,
    this.walletName,
    this.walletType,
    this.walletCurrency,
    required this.type,
    required this.amount,
    required this.currency,
    this.note,
    required this.date,
    this.time,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.category,
  });
}
