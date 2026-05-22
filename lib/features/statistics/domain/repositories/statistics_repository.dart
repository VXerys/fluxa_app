import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_summary_entity.dart';

class GetStatisticsParams {
  final String type;
  final DateTime startDate;
  final DateTime endDate;

  const GetStatisticsParams({
    required this.type,
    required this.startDate,
    required this.endDate,
  });
}

abstract class StatisticsRepository {
  Future<Either<Failure, StatisticsSummaryEntity>> getStatistics(
    GetStatisticsParams params,
  );
}
