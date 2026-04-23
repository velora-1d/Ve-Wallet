import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return BudgetRepositoryImpl(supabase);
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final budgetsStreamProvider = StreamProvider.family<List<BudgetModel>, DateTime>((ref, date) {
  return ref.watch(budgetRepositoryProvider).watchBudgets(date.month, date.year);
});

final budgetsListProvider = FutureProvider.family<List<BudgetModel>, DateTime>((ref, date) {
  return ref.watch(budgetRepositoryProvider).getBudgets(date.month, date.year);
});

class BudgetNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addBudget(BudgetModel budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(budgetRepositoryProvider).addBudget(budget));
    ref.invalidate(budgetsListProvider);
  }

  Future<void> updateBudget(BudgetModel budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(budgetRepositoryProvider).updateBudget(budget));
    ref.invalidate(budgetsListProvider);
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(budgetRepositoryProvider).deleteBudget(id));
    ref.invalidate(budgetsListProvider);
  }
}

final budgetControllerProvider = AsyncNotifierProvider<BudgetNotifier, void>(BudgetNotifier.new);
