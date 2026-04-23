import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories({TransactionType? type});
  Stream<List<CategoryModel>> watchCategories({TransactionType? type});
  Future<CategoryModel> getCategoryById(String id);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}
