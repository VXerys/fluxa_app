import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
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
    return repository.addTransaction(params);
  }

  bool _isValidType(String type) => type == 'income' || type == 'expense';
}
