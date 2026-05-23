import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/monthly_cashflow_comparison_entity.dart';

class GetMonthlyCashflowComparisonUseCase
    implements UseCase<MonthlyCashflowComparisonEntity, NoParams> {
  final TransactionRepository transactionRepository;
  final DateTime Function() nowProvider;

  GetMonthlyCashflowComparisonUseCase({
    required this.transactionRepository,
    DateTime Function()? nowProvider,
  }) : nowProvider = nowProvider ?? DateTime.now;

  @override
  Future<Either<Failure, MonthlyCashflowComparisonEntity>> call(
    NoParams params,
  ) async {
    final now = nowProvider();
    final currentMonthStart = DateTime(now.year, now.month);
    final nextMonthStart = DateTime(now.year, now.month + 1);
    final previousMonthStart = DateTime(now.year, now.month - 1);

    final currentResult = await transactionRepository.getTransactions(
      GetTransactionsParams(
        startDate: currentMonthStart,
        endDate: nextMonthStart,
      ),
    );
    final previousResult = await transactionRepository.getTransactions(
      GetTransactionsParams(
        startDate: previousMonthStart,
        endDate: currentMonthStart,
      ),
    );

    Failure? failure;
    List<TransactionEntity> currentTransactions = <TransactionEntity>[];
    List<TransactionEntity> previousTransactions = <TransactionEntity>[];

    currentResult.fold(
      (currentFailure) => failure = currentFailure,
      (transactions) => currentTransactions = transactions,
    );
    if (failure != null) {
      return Left(failure!);
    }

    previousResult.fold(
      (previousFailure) => failure = previousFailure,
      (transactions) => previousTransactions = transactions,
    );
    if (failure != null) {
      return Left(failure!);
    }

    final currentNet = _calculateNet(currentTransactions);
    final previousNet = _calculateNet(previousTransactions);
    final delta = currentNet - previousNet;
    final hasComparison = previousNet != 0;
    final percentage = hasComparison
        ? (delta / previousNet.abs()) * 100
        : null;

    return Right(
      MonthlyCashflowComparisonEntity(
        currentNet: currentNet,
        previousNet: previousNet,
        delta: delta,
        percentage: percentage,
        hasComparison: hasComparison,
      ),
    );
  }

  double _calculateNet(List<TransactionEntity> transactions) {
    double net = 0;

    for (final transaction in transactions) {
      if (transaction.isDeleted) continue;

      if (transaction.type == 'income') {
        net += transaction.amount;
      } else if (transaction.type == 'expense') {
        net -= transaction.amount;
      }
    }

    return net;
  }
}
