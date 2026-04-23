import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/domain/repositories/category_repository.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseClient _supabase;
  final String _tableName = 'categories';

  CategoryRepositoryImpl(this._supabase);

  @override
  Future<List<CategoryModel>> getCategories({TransactionType? type}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    var query = _supabase.from(_tableName).select().eq('user_id', user.id);
    
    if (type != null) {
      query = query.eq('type', type.name);
    }

    final response = await query.order('name');
    return response.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Stream<List<CategoryModel>> watchCategories({TransactionType? type}) {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    var stream = _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id);

    return stream.map((data) {
      var models = data.map((json) => CategoryModel.fromJson(json)).toList();
      if (type != null) {
        models = models.where((c) => c.type == type).toList();
      }
      models.sort((a, b) => a.name.compareTo(b.name));
      return models;
    });
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('id', id)
        .single();
    
    return CategoryModel.fromJson(response);
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _supabase.from(_tableName).insert(category.toJson());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    if (category.id.isEmpty) throw Exception('Category ID is required for update');
    
    await _supabase
        .from(_tableName)
        .update(category.toJson())
        .eq('id', category.id);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }
}
