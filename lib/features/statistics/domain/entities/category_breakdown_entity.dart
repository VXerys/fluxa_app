class CategoryBreakdownEntity {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategoryBreakdownEntity({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}
