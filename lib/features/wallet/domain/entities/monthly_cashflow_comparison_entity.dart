class MonthlyCashflowComparisonEntity {
  final double currentNet;
  final double previousNet;
  final double delta;
  final double? percentage;
  final bool hasComparison;

  const MonthlyCashflowComparisonEntity({
    required this.currentNet,
    required this.previousNet,
    required this.delta,
    required this.percentage,
    required this.hasComparison,
  });
}
