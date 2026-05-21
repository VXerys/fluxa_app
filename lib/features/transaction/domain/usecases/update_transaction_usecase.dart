import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase
    implements UseCase<TransactionEntity, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    UpdateTransactionParams params,
  ) async {
    if (params.walletId.trim().isEmpty) {
      return const Left(ServerFailure('Wallet is required'));
    }
    return await repository.updateTransaction(params);
  }
}
