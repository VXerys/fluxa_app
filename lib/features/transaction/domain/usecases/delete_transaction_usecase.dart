import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionParams {
  final String transactionId;

  DeleteTransactionParams({required this.transactionId});
}

class DeleteTransactionUseCase
    implements UseCase<void, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransactionUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    return repository.deleteTransaction(params.transactionId);
  }
}
