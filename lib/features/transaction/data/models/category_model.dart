import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    super.userId,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    required super.isSystem,
    required super.sortOrder,
    super.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isSystem: json['is_system'] as bool? ?? false,
      sortOrder: _parseInt(json['sort_order']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_system': isSystem,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      isSystem: isSystem,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
