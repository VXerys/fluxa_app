import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> getWalletById(String id);
  Future<WalletModel> createWallet(WalletModel model);
  Future<WalletModel> updateWallet(WalletModel model);
  Future<void> archiveWallet(String id);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  @override
  Future<List<WalletModel>> getWallets() async {
    final userId = _requireUserId();
    try {
      final response = await _client
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', false)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      final list = response as List;
      return list
          .map((json) => WalletModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WalletModel> getWalletById(String id) async {
    final userId = _requireUserId();
    try {
      final response = await _client
          .from('wallets')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .single();

      return WalletModel.fromJson(response);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WalletModel> createWallet(WalletModel model) async {
    final userId = _requireUserId();
    try {
      final payload = model.toJson();
      payload['user_id'] = userId;

      final response = await _client
          .from('wallets')
          .insert(payload)
          .select()
          .single();

      return WalletModel.fromJson(response);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WalletModel> updateWallet(WalletModel model) async {
    final userId = _requireUserId();
    try {
      final payload = model.toJson();
      payload['user_id'] = userId;
      payload.remove('id');

      final response = await _client
          .from('wallets')
          .update(payload)
          .eq('id', model.id)
          .eq('user_id', userId)
          .select()
          .single();

      return WalletModel.fromJson(response);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> archiveWallet(String id) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('wallets')
          .update({'is_archived': true})
          .eq('id', id)
          .eq('user_id', userId);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
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
}
