import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/domain/repositories/category_repository.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  static const String _internalTransferCategoryName = '__ve_transfer__';

  final SupabaseClient _supabase;
  final String _tableName = 'categories';

  CategoryRepositoryImpl(this._supabase);

  @override
  Future<List<CategoryModel>> getCategories({TransactionType? type}) async {
    final response = await _supabase.from(_tableName).select().order('name');
    final categories = (response as List)
        .where((json) => json['name'] != _internalTransferCategoryName)
        .map((json) => CategoryModel.fromJson(json))
        .toList();

    if (type == null) {
      return categories;
    }

    return categories.where((category) => category.type == type).toList();
  }

  @override
  Stream<List<CategoryModel>> watchCategories({TransactionType? type}) {
    var stream = _supabase
        .from(_tableName)
        .stream(primaryKey: ['id']);

    return stream.map((data) {
      var models = data
          .where((json) => json['name'] != _internalTransferCategoryName)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
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
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) {
      throw Exception('Buat atau gabung shared account dulu sebelum menambah kategori');
    }

    await _supabase.from(_tableName).insert(
          category.copyWith(
            householdId: householdId,
            isDefault: false,
          ).toJson(),
        );
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    if (category.id.isEmpty) throw Exception('Category ID is required for update');
    if (category.isDefault) {
      throw Exception('Kategori bawaan tidak bisa diubah');
    }
    
    await _supabase
        .from(_tableName)
        .update(category.toJson())
        .eq('id', category.id);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }

  Future<String?> _getCurrentHouseholdId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final member = await _supabase
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    return member?['household_id'] as String?;
  }
}
