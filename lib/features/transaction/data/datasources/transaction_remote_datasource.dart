import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';
import '../models/transaction_summary_model.dart';

abstract class TransactionRemoteDataSource {
  Future<TransactionModel> addTransaction(TransactionModel model);
  Future<List<TransactionModel>> getTransactions();
  Future<void> deleteTransaction(String transactionId);
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
          .select('*, category:categories(*)')
          .single();

      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final userId = _requireUserId();
    try {
      final response = await _client
          .from('transactions')
          .select('*, category:categories(*)')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

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
}
