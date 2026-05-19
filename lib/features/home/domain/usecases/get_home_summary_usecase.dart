import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/home_summary_entity.dart';

class GetHomeSummaryUseCase implements UseCase<HomeSummaryEntity, NoParams> {
  final TransactionRepository repository;

  GetHomeSummaryUseCase({required this.repository});

  @override
  Future<Either<Failure, HomeSummaryEntity>> call(NoParams params) async {
    final result = await repository.getTransactions();

    return result.fold((failure) => Left(failure), (transactions) {
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

        final aCreatedAt =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCreatedAt =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bCreatedAt.compareTo(aCreatedAt);
      });

      final recentTransactions = activeTransactions.take(5).toList();

      return Right(
        HomeSummaryEntity(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          recentTransactions: recentTransactions,
        ),
      );
    });
  }
}
