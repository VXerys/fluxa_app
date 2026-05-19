class CategoryEntity {
  final String id;
  final String? userId;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isSystem;
  final int sortOrder;
  final DateTime? createdAt;

  CategoryEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isSystem,
    required this.sortOrder,
    this.createdAt,
  });
}
