import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../entities/home_summary_entity.dart';

class GetHomeSummaryUseCase implements UseCase<HomeSummaryEntity, NoParams> {
  final TransactionRepository transactionRepository;
  final WalletRepository walletRepository;

  GetHomeSummaryUseCase({
    required this.transactionRepository,
    required this.walletRepository,
  });

  @override
  Future<Either<Failure, HomeSummaryEntity>> call(NoParams params) async {
    final transactionsResult = await transactionRepository.getTransactions(
      GetTransactionsParams(),
    );
    final totalBalanceResult = await walletRepository.getTotalBalance();

    return transactionsResult.fold((failure) => Left(failure), (transactions) {
      return totalBalanceResult.fold((failure) => Left(failure), (
        totalBalance,
      ) {
        final activeTransactions = transactions
            .where((transaction) => !transaction.isDeleted)
            .toList();

        double totalIncome = 0;
        double totalExpense = 0;

        for (final transaction in activeTransactions) {
          if (transaction.type == 'income') {
            totalIncome += transaction.amount;
          } else if (transaction.type == 'expense') {
            totalExpense += transaction.amount;
          }
        }

        activeTransactions.sort((a, b) {
          final dateCompare = b.date.compareTo(a.date);
          if (dateCompare != 0) {
            return dateCompare;
          }

          final aCreatedAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bCreatedAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          return bCreatedAt.compareTo(aCreatedAt);
        });

        final grouped = _buildRecentGroups(activeTransactions);

        return Right(
          HomeSummaryEntity(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            balance: totalBalance,
            recentTransactionGroups: grouped.groups,
            hasMoreRecentTransactions: grouped.hasMore,
          ),
        );
      });
    });
  }

  _RecentGroupResult _buildRecentGroups(List<TransactionEntity> sorted) {
    final Map<DateTime, List<TransactionEntity>> groupedByDate =
        <DateTime, List<TransactionEntity>>{};

    for (final transaction in sorted) {
      final dateOnly = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groupedByDate.putIfAbsent(dateOnly, () => <TransactionEntity>[]);
      groupedByDate[dateOnly]!.add(transaction);
    }

    final sortedDates = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final List<HomeTransactionGroupEntity> groups = <HomeTransactionGroupEntity>[];
    int shownCount = 0;

    for (final date in sortedDates) {
      if (groups.length >= 3 || shownCount >= 6) break;

      final dayTransactions = groupedByDate[date]!;
      final visible = <TransactionEntity>[];

      for (final tx in dayTransactions) {
        if (shownCount >= 6) break;
        visible.add(tx);
        shownCount++;
      }

      if (visible.isEmpty) continue;

      double netAmount = 0;
      for (final tx in dayTransactions) {
        if (tx.type == 'income') {
          netAmount += tx.amount;
        } else {
          netAmount -= tx.amount;
        }
      }

      groups.add(
        HomeTransactionGroupEntity(
          date: date,
          transactions: visible,
          netAmount: netAmount,
        ),
      );
    }

    return _RecentGroupResult(
      groups: groups,
      hasMore: sorted.length > shownCount,
    );
  }
}

class _RecentGroupResult {
  final List<HomeTransactionGroupEntity> groups;
  final bool hasMore;

  const _RecentGroupResult({
    required this.groups,
    required this.hasMore,
  });
}
