import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/transaction_summary_entity.dart';

class AddTransactionParams {
  final String type;
  final double amount;
  final String? categoryId;
  final String walletId;
  final String? note;
  final DateTime date;
  final String? time;

  AddTransactionParams({
    required this.type,
    required this.amount,
    this.categoryId,
    required this.walletId,
    this.note,
    required this.date,
    this.time,
  });
}

class UpdateTransactionParams {
  final String id;
  final String type;
  final double amount;
  final String? categoryId;
  final String walletId;
  final String? note;
  final DateTime date;
  final String? time;

  UpdateTransactionParams({
    required this.id,
    required this.type,
    required this.amount,
    this.categoryId,
    required this.walletId,
    this.note,
    required this.date,
    this.time,
  });
}

class GetTransactionsParams {
  final String? type;
  final String? categoryId;
  final List<String>? categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy; // 'dateDesc', 'dateAsc', 'amountDesc', 'amountAsc'
  final double? minAmount;
  final double? maxAmount;

  GetTransactionsParams({
    this.type,
    this.categoryId,
    this.categoryIds,
    this.startDate,
    this.endDate,
    this.sortBy,
    this.minAmount,
    this.maxAmount,
  });
}

abstract class TransactionRepository {
  Future<Either<Failure, TransactionEntity>> addTransaction(
    AddTransactionParams params,
  );
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    GetTransactionsParams params,
  );
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    UpdateTransactionParams params,
  );
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
  Future<Either<Failure, TransactionSummaryEntity>> getTransactionSummary();
}
