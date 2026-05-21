// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateUser({required String displayName});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Sign up failed');
      }

      final trimmedName = displayName.trim();

      await _client.from('profiles').upsert({
        'id': user.id,
        if (trimmedName.isNotEmpty) 'display_name': trimmedName,
      }, onConflict: 'id');

      final profile = await _client
          .from('profiles')
          .select('id, username, display_name, avatar_url, is_pro')
          .eq('id', user.id)
          .maybeSingle();
      return UserModel.fromSupabaseUser(user, profile: profile);
    } on AuthException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Sign in failed');
      }

      final profile = await _fetchProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile: profile);
    } on AuthException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final profile = await _fetchProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile: profile);
    } on AuthException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUser({required String displayName}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AuthException('Not authenticated');
    }

    try {
      final trimmedName = displayName.trim();

      await _client
          .from('profiles')
          .update({if (trimmedName.isNotEmpty) 'display_name': trimmedName})
          .eq('id', user.id);

      final profile = await _fetchProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile: profile);
    } on AuthException {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> _fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select('id, username, display_name, avatar_url, is_pro')
        .eq('id', userId)
        .single();
    return response as Map<String, dynamic>;
  }
}
