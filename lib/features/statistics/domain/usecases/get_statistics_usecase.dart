import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/statistics_summary_entity.dart';
import '../repositories/statistics_repository.dart';

class GetStatisticsUseCase
    implements UseCase<StatisticsSummaryEntity, GetStatisticsParams> {
  final StatisticsRepository repository;

  GetStatisticsUseCase({required this.repository});

  @override
  Future<Either<Failure, StatisticsSummaryEntity>> call(
    GetStatisticsParams params,
  ) async {
    if (params.startDate.isAfter(params.endDate)) {
      return const Left(
        ServerFailure('Start date cannot be after end date'),
      );
    }
    return repository.getStatistics(params);
  }
}
