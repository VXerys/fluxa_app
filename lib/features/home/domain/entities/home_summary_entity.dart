import '../../../transaction/domain/entities/transaction_entity.dart';

class HomeSummaryEntity {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<TransactionEntity> recentTransactions;

  HomeSummaryEntity({
    required this.totalIncome,
    required this.totalExpense,
    required List<TransactionEntity> recentTransactions,
  }) : balance = totalIncome - totalExpense,
       recentTransactions = recentTransactions;
}
