import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/category/data/repositories/category_repository_impl.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/domain/repositories/category_repository.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(Supabase.instance.client);
});

final categoriesStreamProvider = StreamProvider.family<List<CategoryModel>, TransactionType?>((ref, type) {
  return ref.watch(categoryRepositoryProvider).watchCategories(type: type);
});

final categoriesProvider = FutureProvider.family<List<CategoryModel>, TransactionType?>((ref, type) {
  return ref.watch(categoryRepositoryProvider).getCategories(type: type);
});

final categoryControllerProvider = AsyncNotifierProvider<CategoryNotifier, void>(() {
  return CategoryNotifier();
});

class CategoryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).addCategory(category),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).updateCategory(category),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).deleteCategory(id),
    );
    if (state.hasError) {
      throw state.error!;
    }
  }
}
