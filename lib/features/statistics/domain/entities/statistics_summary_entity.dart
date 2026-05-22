import 'category_breakdown_entity.dart';

class StatisticsSummaryEntity {
  final double totalAmount;
  final String type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<CategoryBreakdownEntity> breakdown;

  const StatisticsSummaryEntity({
    required this.totalAmount,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.breakdown,
  });
}
