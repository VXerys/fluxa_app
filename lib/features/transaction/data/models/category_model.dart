import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    super.userId,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    required super.isSystem,
    super.parentId,
    required super.sortOrder,
    super.createdAt,
    super.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final parsedChildren = rawChildren is List
        ? rawChildren
              .whereType<Map<String, dynamic>>()
              .map(CategoryModel.fromJson)
              .toList()
        : const <CategoryModel>[];

    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isSystem: json['is_system'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
      sortOrder: _parseInt(json['sort_order']),
      createdAt: _parseDate(json['created_at']),
      children: parsedChildren,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    bool? isSystem,
    String? parentId,
    int? sortOrder,
    DateTime? createdAt,
    List<CategoryEntity>? children,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
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
      'parent_id': parentId,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      if (children.isNotEmpty)
        'children': children
            .map(
              (child) => child is CategoryModel
                  ? child.toJson()
                  : CategoryModel.fromEntity(child).toJson(),
            )
            .toList(),
    }..removeWhere((key, value) => value == null);
  }

  CategoryEntity toEntity() {
    final mappedChildren = children
        .map((child) => child is CategoryModel ? child.toEntity() : child)
        .toList();

    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      isSystem: isSystem,
      parentId: parentId,
      sortOrder: sortOrder,
      createdAt: createdAt,
      children: mappedChildren,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
      color: entity.color,
      isSystem: entity.isSystem,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      children: entity.children,
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
