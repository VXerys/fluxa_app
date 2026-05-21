import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase
    implements UseCase<TransactionEntity, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransactionUseCase({required this.repository});

  @override
  Future<Either<Failure, TransactionEntity>> call(
    AddTransactionParams params,
  ) async {
    if (params.amount <= 0) {
      return Left(ServerFailure('Amount must be greater than 0'));
    }
    if (!_isValidType(params.type)) {
      return Left(ServerFailure('Invalid transaction type'));
    }
    if (params.walletId.trim().isEmpty) {
      return Left(ServerFailure('Wallet is required'));
    }
    return repository.addTransaction(params);
  }

  bool _isValidType(String type) => type == 'income' || type == 'expense';
}
