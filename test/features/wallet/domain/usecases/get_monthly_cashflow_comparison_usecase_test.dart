import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxa_app/core/errors/failures.dart';
import 'package:fluxa_app/core/usecases/usecase.dart';
import 'package:fluxa_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:fluxa_app/features/transaction/domain/entities/transaction_summary_entity.dart';
import 'package:fluxa_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:fluxa_app/features/wallet/domain/usecases/get_monthly_cashflow_comparison_usecase.dart';

void main() {
  group('GetMonthlyCashflowComparisonUseCase', () {
    test('calculates monthly net delta and percentage', () async {
      final repository = _FakeTransactionRepository(
        transactions: <TransactionEntity>[
          _transaction(type: 'income', amount: 2000000, date: DateTime(2026, 5, 5)),
          _transaction(type: 'expense', amount: 500000, date: DateTime(2026, 5, 10)),
          _transaction(type: 'income', amount: 1800000, date: DateTime(2026, 4, 5)),
          _transaction(type: 'expense', amount: 600000, date: DateTime(2026, 4, 10)),
        ],
      );
      final useCase = GetMonthlyCashflowComparisonUseCase(
        transactionRepository: repository,
        nowProvider: () => DateTime(2026, 5, 23),
      );

      final result = await useCase(const NoParams());

      result.fold((failure) => fail(failure.message), (comparison) {
        expect(comparison.currentNet, 1500000);
        expect(comparison.previousNet, 1200000);
        expect(comparison.delta, 300000);
        expect(comparison.percentage, 25);
        expect(comparison.hasComparison, isTrue);
      });
    });

    test('returns no comparison when previous month net is zero', () async {
      final repository = _FakeTransactionRepository(
        transactions: <TransactionEntity>[
          _transaction(type: 'income', amount: 1000000, date: DateTime(2026, 5, 1)),
          _transaction(type: 'expense', amount: 250000, date: DateTime(2026, 5, 2)),
          _transaction(type: 'income', amount: 500000, date: DateTime(2026, 4, 1)),
          _transaction(type: 'expense', amount: 500000, date: DateTime(2026, 4, 2)),
        ],
      );
      final useCase = GetMonthlyCashflowComparisonUseCase(
        transactionRepository: repository,
        nowProvider: () => DateTime(2026, 5, 23),
      );

      final result = await useCase(const NoParams());

      result.fold((failure) => fail(failure.message), (comparison) {
        expect(comparison.currentNet, 750000);
        expect(comparison.previousNet, 0);
        expect(comparison.delta, 750000);
        expect(comparison.percentage, isNull);
        expect(comparison.hasComparison, isFalse);
      });
    });

    test('uses absolute previous net when previous month is negative', () async {
      final repository = _FakeTransactionRepository(
        transactions: <TransactionEntity>[
          _transaction(type: 'income', amount: 1000000, date: DateTime(2026, 5, 1)),
          _transaction(type: 'expense', amount: 200000, date: DateTime(2026, 5, 2)),
          _transaction(type: 'income', amount: 200000, date: DateTime(2026, 4, 1)),
          _transaction(type: 'expense', amount: 1000000, date: DateTime(2026, 4, 2)),
        ],
      );
      final useCase = GetMonthlyCashflowComparisonUseCase(
        transactionRepository: repository,
        nowProvider: () => DateTime(2026, 5, 23),
      );

      final result = await useCase(const NoParams());

      result.fold((failure) => fail(failure.message), (comparison) {
        expect(comparison.currentNet, 800000);
        expect(comparison.previousNet, -800000);
        expect(comparison.delta, 1600000);
        expect(comparison.percentage, 200);
        expect(comparison.hasComparison, isTrue);
      });
    });

    test('uses calendar month boundaries only', () async {
      final repository = _FakeTransactionRepository(
        transactions: <TransactionEntity>[
          _transaction(type: 'income', amount: 999999, date: DateTime(2026, 3, 31)),
          _transaction(type: 'income', amount: 100000, date: DateTime(2026, 4, 1)),
          _transaction(type: 'income', amount: 200000, date: DateTime(2026, 4, 30)),
          _transaction(type: 'income', amount: 400000, date: DateTime(2026, 5, 1)),
          _transaction(type: 'expense', amount: 100000, date: DateTime(2026, 5, 31)),
          _transaction(type: 'income', amount: 999999, date: DateTime(2026, 6, 1)),
        ],
      );
      final useCase = GetMonthlyCashflowComparisonUseCase(
        transactionRepository: repository,
        nowProvider: () => DateTime(2026, 5, 23),
      );

      final result = await useCase(const NoParams());

      result.fold((failure) => fail(failure.message), (comparison) {
        expect(comparison.currentNet, 300000);
        expect(comparison.previousNet, 300000);
        expect(comparison.delta, 0);
        expect(comparison.percentage, 0);
        expect(comparison.hasComparison, isTrue);
      });
      expect(repository.params, hasLength(2));
      expect(repository.params[0].startDate, DateTime(2026, 5));
      expect(repository.params[0].endDate, DateTime(2026, 6));
      expect(repository.params[1].startDate, DateTime(2026, 4));
      expect(repository.params[1].endDate, DateTime(2026, 5));
    });
  });
}

class _FakeTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> transactions;
  final List<GetTransactionsParams> params = <GetTransactionsParams>[];

  _FakeTransactionRepository({required this.transactions});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    GetTransactionsParams params,
  ) async {
    this.params.add(params);
    return Right(
      transactions.where((transaction) {
        final startDate = params.startDate;
        final endDate = params.endDate;

        if (startDate != null && transaction.date.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && !transaction.date.isBefore(endDate)) {
          return false;
        }

        return true;
      }).toList(),
    );
  }

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(
    AddTransactionParams params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionSummaryEntity>> getTransactionSummary() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    UpdateTransactionParams params,
  ) {
    throw UnimplementedError();
  }
}

TransactionEntity _transaction({
  required String type,
  required double amount,
  required DateTime date,
  bool isDeleted = false,
}) {
  return TransactionEntity(
    id: '${type}_${amount}_$date',
    userId: 'user-id',
    type: type,
    amount: amount,
    currency: 'IDR',
    date: date,
    isDeleted: isDeleted,
  );
}
