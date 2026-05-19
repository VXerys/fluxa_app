import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/transaction_entity.dart';
import '../entities/transaction_summary_entity.dart';

class AddTransactionParams {
  final String type;
  final double amount;
  final String? categoryId;
  final String? note;
  final DateTime date;
  final String? time;

  AddTransactionParams({
    required this.type,
    required this.amount,
    this.categoryId,
    this.note,
    required this.date,
    this.time,
  });
}

abstract class TransactionRepository {
  Future<Either<Failure, TransactionEntity>> addTransaction(
    AddTransactionParams params,
  );
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
  Future<Either<Failure, TransactionSummaryEntity>> getTransactionSummary();
}
