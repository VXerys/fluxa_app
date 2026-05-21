class CategoryEntity {
  final String id;
  final String? userId;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isSystem;
  final String? parentId;
  final int sortOrder;
  final DateTime? createdAt;
  final List<CategoryEntity> children;

  const CategoryEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isSystem,
    this.parentId,
    required this.sortOrder,
    this.createdAt,
    this.children = const <CategoryEntity>[],
  });
}
