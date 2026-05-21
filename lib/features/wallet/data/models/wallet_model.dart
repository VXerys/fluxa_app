import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.currency,
    super.icon,
    super.color,
    required super.isArchived,
    required super.includeInTotal,
    required super.sortOrder,
    super.createdAt,
    super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'cash',
      balance: _parseAmount(json['balance']),
      currency: json['currency'] as String? ?? 'IDR',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isArchived: _parseBool(json['is_archived'], defaultValue: false),
      includeInTotal: _parseBool(
        json['include_in_total'],
        defaultValue: true,
      ),
      sortOrder: _parseSortOrder(json['sort_order']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'is_archived': isArchived,
      'include_in_total': includeInTotal,
      'sort_order': sortOrder,
    };
    if (id.isNotEmpty) {
      payload['id'] = id;
    }
    payload.removeWhere((key, value) => value == null);
    return payload;
  }

  WalletEntity toEntity() {
    return WalletEntity(
      id: id,
      userId: userId,
      name: name,
      type: type,
      balance: balance,
      currency: currency,
      icon: icon,
      color: color,
      isArchived: isArchived,
      includeInTotal: includeInTotal,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return defaultValue;
  }

  static int _parseSortOrder(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
