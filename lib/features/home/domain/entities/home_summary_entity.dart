import '../../../transaction/domain/entities/transaction_entity.dart';

class HomeTransactionGroupEntity {
  final DateTime date;
  final List<TransactionEntity> transactions;
  final double netAmount;

  const HomeTransactionGroupEntity({
    required this.date,
    required this.transactions,
    required this.netAmount,
  });
}

class HomeSummaryEntity {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<HomeTransactionGroupEntity> recentTransactionGroups;
  final bool hasMoreRecentTransactions;

  const HomeSummaryEntity({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.recentTransactionGroups,
    required this.hasMoreRecentTransactions,
  });
}
