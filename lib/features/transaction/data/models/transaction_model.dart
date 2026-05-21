import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'category_model.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.userId,
    super.categoryId,
    super.walletId,
    super.walletName,
    super.walletType,
    super.walletCurrency,
    required super.type,
    required super.amount,
    required super.currency,
    super.note,
    required super.date,
    super.time,
    required super.isDeleted,
    super.createdAt,
    super.updatedAt,
    super.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    CategoryEntity? category;
    if (categoryJson is Map<String, dynamic>) {
      category = CategoryModel.fromJson(categoryJson);
    }

    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      walletId: json['wallet_id'] as String?,
      walletName: _parseWalletField(json['wallet'], 'name'),
      walletType: _parseWalletField(json['wallet'], 'type'),
      walletCurrency: _parseWalletField(json['wallet'], 'currency'),
      type: json['type'] as String? ?? 'expense',
      amount: _parseAmount(json['amount']),
      currency: json['currency'] as String? ?? 'IDR',
      note: json['note'] as String?,
      date: _parseDate(json['date']),
      time: json['time'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'user_id': userId,
      'category_id': categoryId,
      'wallet_id': walletId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'note': note,
      'date': _formatDate(date),
      'time': time,
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    if (id.isNotEmpty) {
      payload['id'] = id;
    }
    payload.removeWhere((key, value) => value == null);
    return payload;
  }

  TransactionEntity toEntity() {
    final CategoryEntity? mappedCategory = category is CategoryModel
        ? (category as CategoryModel).toEntity()
        : category;
    return TransactionEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      walletId: walletId,
      walletName: walletName,
      walletType: walletType,
      walletCurrency: walletCurrency,
      type: type,
      amount: amount,
      currency: currency,
      note: note,
      date: date,
      time: time,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: mappedCategory,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String? _parseWalletField(dynamic wallet, String key) {
    if (wallet is Map) {
      final value = wallet[key];
      if (value is String) return value;
    }
    return null;
  }
}
