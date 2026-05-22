class TopExpenseTransactionEntity {
  final String transactionId;
  final double amount;
  final DateTime date;
  final String title;
  final String? note;
  final String? walletName;
  final String? categoryName;
  final String? subcategoryName;
  final String groupKey;
  final String groupLabel;

  const TopExpenseTransactionEntity({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.title,
    this.note,
    this.walletName,
    this.categoryName,
    this.subcategoryName,
    required this.groupKey,
    required this.groupLabel,
  });
}
