import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../transaction/domain/entities/category_entity.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../domain/entities/category_breakdown_entity.dart';
import '../../domain/entities/statistics_summary_entity.dart';
import '../../domain/entities/top_expense_transaction_entity.dart';
import '../../domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final TransactionRepository transactionRepository;

  StatisticsRepositoryImpl({required this.transactionRepository});

  @override
  Future<Either<Failure, StatisticsSummaryEntity>> getStatistics(
    GetStatisticsParams params,
  ) async {
    try {
      final transactionsResult = await transactionRepository.getTransactions(
        GetTransactionsParams(
          type: params.type,
          startDate: params.startDate,
          endDate: params.endDate,
        ),
      );

      return transactionsResult.fold(
        (failure) => Left(failure),
        (transactions) => Right(_buildSummary(params, transactions)),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  StatisticsSummaryEntity _buildSummary(
    GetStatisticsParams params,
    List<TransactionEntity> transactions,
  ) {
    final Map<String, CategoryEntity> categoriesById = <String, CategoryEntity>{
      for (final transaction in transactions)
        if (transaction.category != null) transaction.category!.id: transaction.category!,
    };

    final Map<String, _CategoryAggregation> grouped = <String, _CategoryAggregation>{};
    double totalAmount = 0;

    for (final transaction in transactions) {
      final resolvedCategory = _resolveGroupingCategory(
        transaction.category,
        categoriesById,
        params.type,
      );
      final amount = transaction.amount;
      totalAmount += amount;

      final existing = grouped[resolvedCategory.id];
      if (existing != null) {
        existing.amount += amount;
        existing.transactionCount += 1;
      } else {
        grouped[resolvedCategory.id] = _CategoryAggregation(
          categoryId: resolvedCategory.id,
          categoryName: resolvedCategory.name,
          categoryIcon: resolvedCategory.icon,
          categoryColor: resolvedCategory.color,
          amount: amount,
          transactionCount: 1,
        );
      }
    }

    final breakdown = grouped.values
        .map((group) {
          final percentage = totalAmount > 0
              ? (group.amount / totalAmount) * 100
              : 0.0;
          return CategoryBreakdownEntity(
            categoryId: group.categoryId,
            categoryName: group.categoryName,
            categoryIcon: group.categoryIcon,
            categoryColor: group.categoryColor,
            amount: group.amount,
            percentage: percentage,
            transactionCount: group.transactionCount,
          );
        })
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final topTransactionsByGroup = _buildTopTransactionsByGroup(
      transactions: transactions,
      categoriesById: categoriesById,
    );

    return StatisticsSummaryEntity(
      totalAmount: totalAmount,
      type: params.type,
      periodStart: params.startDate,
      periodEnd: params.endDate,
      breakdown: breakdown,
      topTransactionsByGroup: topTransactionsByGroup,
    );
  }

  Map<String, List<TopExpenseTransactionEntity>> _buildTopTransactionsByGroup({
    required List<TransactionEntity> transactions,
    required Map<String, CategoryEntity> categoriesById,
  }) {
    final Map<String, List<TopExpenseTransactionEntity>> grouped =
        <String, List<TopExpenseTransactionEntity>>{
          'Kategori': <TopExpenseTransactionEntity>[],
          'Subkategori': <TopExpenseTransactionEntity>[],
          'Judul': <TopExpenseTransactionEntity>[],
          'Dompet': <TopExpenseTransactionEntity>[],
        };

    for (final transaction in transactions) {
      final category = transaction.category;
      final subcategoryName = category?.name;
      final parentCategory = _resolveParentCategory(category, categoriesById);
      final parentCategoryName = parentCategory?.name ?? subcategoryName ?? 'Uncategorized';
      final walletName = transaction.walletName?.trim();
      final normalizedWalletName = (walletName == null || walletName.isEmpty)
          ? 'Tanpa Dompet'
          : walletName;
      final note = transaction.note?.trim();
      final titleFromNote = (note == null || note.isEmpty)
          ? parentCategoryName
          : note;

      grouped['Kategori']!.add(
        TopExpenseTransactionEntity(
          transactionId: transaction.id,
          amount: transaction.amount,
          date: transaction.date,
          title: titleFromNote,
          note: transaction.note,
          walletName: normalizedWalletName,
          categoryName: parentCategoryName,
          subcategoryName: subcategoryName,
          groupKey: parentCategory?.id ?? category?.id ?? 'uncategorized',
          groupLabel: parentCategoryName,
        ),
      );
      grouped['Subkategori']!.add(
        TopExpenseTransactionEntity(
          transactionId: transaction.id,
          amount: transaction.amount,
          date: transaction.date,
          title: titleFromNote,
          note: transaction.note,
          walletName: normalizedWalletName,
          categoryName: parentCategoryName,
          subcategoryName: subcategoryName ?? parentCategoryName,
          groupKey: category?.id ?? parentCategory?.id ?? 'uncategorized',
          groupLabel: subcategoryName ?? parentCategoryName,
        ),
      );
      grouped['Judul']!.add(
        TopExpenseTransactionEntity(
          transactionId: transaction.id,
          amount: transaction.amount,
          date: transaction.date,
          title: titleFromNote,
          note: transaction.note,
          walletName: normalizedWalletName,
          categoryName: parentCategoryName,
          subcategoryName: subcategoryName,
          groupKey: titleFromNote.toLowerCase(),
          groupLabel: titleFromNote,
        ),
      );
      grouped['Dompet']!.add(
        TopExpenseTransactionEntity(
          transactionId: transaction.id,
          amount: transaction.amount,
          date: transaction.date,
          title: titleFromNote,
          note: transaction.note,
          walletName: normalizedWalletName,
          categoryName: parentCategoryName,
          subcategoryName: subcategoryName,
          groupKey: transaction.walletId ?? 'wallet-unknown',
          groupLabel: normalizedWalletName,
        ),
      );
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final amountCompare = b.amount.compareTo(a.amount);
        if (amountCompare != 0) return amountCompare;
        return b.date.compareTo(a.date);
      });
    }

    return grouped;
  }

  CategoryEntity _resolveGroupingCategory(
    CategoryEntity? category,
    Map<String, CategoryEntity> categoriesById,
    String fallbackType,
  ) {
    if (category == null) {
      return CategoryEntity(
        id: 'uncategorized',
        name: 'Uncategorized',
        type: fallbackType,
        isSystem: true,
        sortOrder: 0,
      );
    }

    if (category.parentId != null) {
      final parent = categoriesById[category.parentId!];
      if (parent != null) {
        return parent;
      }
      return CategoryEntity(
        id: category.parentId!,
        name: category.name,
        type: category.type,
        icon: category.icon,
        color: category.color,
        isSystem: category.isSystem,
        sortOrder: category.sortOrder,
      );
    }

    return category;
  }

  CategoryEntity? _resolveParentCategory(
    CategoryEntity? category,
    Map<String, CategoryEntity> categoriesById,
  ) {
    if (category == null) return null;
    if (category.parentId == null) return category;
    return categoriesById[category.parentId!] ?? category;
  }
}

class _CategoryAggregation {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  double amount;
  int transactionCount;

  _CategoryAggregation({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.amount,
    required this.transactionCount,
  });
}
