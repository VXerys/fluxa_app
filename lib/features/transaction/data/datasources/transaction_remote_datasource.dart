import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';
import '../models/transaction_summary_model.dart';
import '../../domain/repositories/transaction_repository.dart';

abstract class TransactionRemoteDataSource {
  Future<TransactionModel> addTransaction(TransactionModel model);
  Future<List<TransactionModel>> getTransactions(GetTransactionsParams params);
  Future<void> deleteTransaction(String transactionId);
  Future<TransactionModel> updateTransaction(TransactionModel model);
  Future<TransactionSummaryModel> getTransactionSummary();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  @override
  Future<TransactionModel> addTransaction(TransactionModel model) async {
    final userId = _requireUserId();
    try {
      final payload = model.toJson();
      payload['user_id'] = userId;

      final response = await _client
          .from('transactions')
          .insert(payload)
          .select(
            '*, category:categories(*), wallet:wallets(id,name,type,currency)',
          )
          .single();

      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    GetTransactionsParams params,
  ) async {
    final userId = _requireUserId();
    try {
      var filterQuery = _client
          .from('transactions')
          .select(
            '*, category:categories(*), wallet:wallets(id,name,type,currency)',
          )
          .eq('user_id', userId)
          .eq('is_deleted', false);

      if (params.type != null) {
        filterQuery = filterQuery.eq('type', params.type!);
      }

      if (params.categoryId != null) {
        filterQuery = filterQuery.eq('category_id', params.categoryId!);
      }

      if (params.startDate != null) {
        filterQuery = filterQuery.gte('date', _formatDate(params.startDate!));
      }

      if (params.endDate != null) {
        filterQuery = filterQuery.lt('date', _formatDate(params.endDate!));
      }

      if (params.minAmount != null) {
        filterQuery = filterQuery.gte('amount', params.minAmount!);
      }

      if (params.maxAmount != null) {
        filterQuery = filterQuery.lte('amount', params.maxAmount!);
      }

      dynamic sortedQuery;
      if (params.sortBy == 'dateAsc') {
        sortedQuery = filterQuery.order('date', ascending: true);
      } else if (params.sortBy == 'amountDesc') {
        sortedQuery = filterQuery.order('amount', ascending: false);
      } else if (params.sortBy == 'amountAsc') {
        sortedQuery = filterQuery.order('amount', ascending: true);
      } else {
        // default dateDesc
        sortedQuery = filterQuery.order('date', ascending: false);
      }

      // Always add created_at as secondary sort for stable sorting
      final response = await sortedQuery.order('created_at', ascending: false);

      final list = response as List;
      return list
          .map(
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('transactions')
          .update({'is_deleted': true})
          .eq('id', transactionId)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel model) async {
    final userId = _requireUserId();
    try {
      final payload = model.toJson();
      payload['user_id'] = userId;
      // Remove fields that should not be updated directly like this or that might cause issues if not managed
      payload.remove('created_at');
      payload.remove('updated_at');

      final response = await _client
          .from('transactions')
          .update(payload)
          .eq('id', model.id)
          .eq('user_id', userId)
          .select(
            '*, category:categories(*), wallet:wallets(id,name,type,currency)',
          )
          .single();

      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TransactionSummaryModel> getTransactionSummary() async {
    final userId = _requireUserId();
    try {
       final response = await _client
           .from('transactions')
           .select('type, amount')
           .eq('user_id', userId)
           .eq('is_deleted', false);

      final list = response as List;
      double totalIncome = 0;
      double totalExpense = 0;

      for (final item in list) {
        final data = item as Map<String, dynamic>;
        final type = data['type'] as String?;
        final amount = _parseAmount(data['amount']);
        if (type == 'income') {
          totalIncome += amount;
        } else if (type == 'expense') {
          totalExpense += amount;
        }
      }

      return TransactionSummaryModel(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw AuthException('User not authenticated');
    }
    return userId;
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
