import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase
    implements UseCase<List<TransactionEntity>, GetTransactionsParams> {
  final TransactionRepository repository;

  GetTransactionsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(GetTransactionsParams params) async {
    return repository.getTransactions(params);
  }
}
