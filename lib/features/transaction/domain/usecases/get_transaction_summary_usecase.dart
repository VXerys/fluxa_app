import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_summary_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionSummaryUseCase
    implements UseCase<TransactionSummaryEntity, NoParams> {
  final TransactionRepository repository;

  GetTransactionSummaryUseCase({required this.repository});

  @override
  Future<Either<Failure, TransactionSummaryEntity>> call(
    NoParams params,
  ) async {
    return repository.getTransactionSummary();
  }
}
