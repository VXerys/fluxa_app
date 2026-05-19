import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getSystemCategories();
  Future<List<CategoryModel>> getCategoriesByType(String type);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  @override
  Future<List<CategoryModel>> getSystemCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_system', true)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return _mapList(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    if (!_isValidType(type)) {
      throw ServerException('Invalid category type');
    }
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_system', true)
          .eq('type', type)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return _mapList(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  bool _isValidType(String type) => type == 'income' || type == 'expense';

  List<CategoryModel> _mapList(dynamic response) {
    final list = response as List;
    return list
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
