import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getSystemCategories();
  Future<List<CategoryModel>> getCategoriesByType(String type);
  Future<List<CategoryModel>> getParentCategoriesByType(String type);
  Future<List<CategoryModel>> getChildCategories(String parentId);
  Future<List<CategoryModel>> getCategoryTreeByType(String type);
  Future<List<CategoryModel>> getAllSystemCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  @override
  Future<List<CategoryModel>> getSystemCategories() async {
    return getAllSystemCategories();
  }

  @override
  Future<List<CategoryModel>> getAllSystemCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_system', true)
          .order('type', ascending: true)
          .order('parent_id', ascending: true)
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

  @override
  Future<List<CategoryModel>> getParentCategoriesByType(String type) async {
    final categories = await getCategoriesByType(type);
    return categories
        .where(
          (category) =>
              category.parentId == null && _isHierarchyReadyParent(category),
        )
        .toList();
  }

  @override
  Future<List<CategoryModel>> getChildCategories(String parentId) async {
    if (parentId.isEmpty) {
      throw ServerException('Invalid parent category id');
    }

    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_system', true)
          .eq('parent_id', parentId)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return _mapList(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CategoryModel>> getCategoryTreeByType(String type) async {
    final categories = await getCategoriesByType(type);
    final childrenByParentId = <String, List<CategoryModel>>{};

    for (final category in categories) {
      final parentId = category.parentId;
      if (parentId == null) continue;
      childrenByParentId
          .putIfAbsent(parentId, () => <CategoryModel>[])
          .add(category);
    }

    return categories
        .where(
          (category) =>
              category.parentId == null && _isHierarchyReadyParent(category),
        )
        .map(
          (parent) => parent.copyWith(
            children: childrenByParentId[parent.id] ?? const <CategoryModel>[],
          ),
        )
        .toList();
  }

  bool _isValidType(String type) => type == 'income' || type == 'expense';

  bool _isHierarchyReadyParent(CategoryModel category) {
    return category.icon != null &&
        category.icon!.isNotEmpty &&
        category.color != null &&
        category.color!.isNotEmpty &&
        category.sortOrder > 0;
  }

  List<CategoryModel> _mapList(dynamic response) {
    final list = response as List;
    return list
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
