import 'category_breakdown_entity.dart';
import 'top_expense_transaction_entity.dart';

class StatisticsSummaryEntity {
  final double totalAmount;
  final String type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<CategoryBreakdownEntity> breakdown;
  final Map<String, List<TopExpenseTransactionEntity>> topTransactionsByGroup;

  const StatisticsSummaryEntity({
    required this.totalAmount,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.breakdown,
    this.topTransactionsByGroup = const <String, List<TopExpenseTransactionEntity>>{},
  });
}
