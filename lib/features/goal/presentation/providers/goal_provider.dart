import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/models/goal_model.dart';
import '../../domain/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return GoalRepositoryImpl(supabase);
});

final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  return ref.watch(goalRepositoryProvider).watchGoals();
});

final goalsListProvider = FutureProvider<List<GoalModel>>((ref) {
  return ref.watch(goalRepositoryProvider).getGoals();
});

final goalDetailProvider = FutureProvider.family<GoalModel, String>((ref, id) {
  return ref.watch(goalRepositoryProvider).getGoalById(id);
});

final goalAllocationsStreamProvider = StreamProvider.family<List<GoalAllocationModel>, String>((ref, goalId) {
  return ref.watch(goalRepositoryProvider).watchAllocations(goalId);
});

class GoalNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addGoal(GoalModel goal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(goalRepositoryProvider).addGoal(goal));
    ref.invalidate(goalsListProvider);
  }

  Future<void> updateGoal(GoalModel goal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(goalRepositoryProvider).updateGoal(goal));
    ref.invalidate(goalsListProvider);
    ref.invalidate(goalDetailProvider(goal.id));
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(goalRepositoryProvider).deleteGoal(id));
    ref.invalidate(goalsListProvider);
  }

  Future<void> addAllocation(GoalAllocationModel allocation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(goalRepositoryProvider).addAllocation(allocation));
    ref.invalidate(goalAllocationsStreamProvider(allocation.goalId));
    ref.invalidate(goalDetailProvider(allocation.goalId));
    ref.invalidate(goalsListProvider);
  }

  Future<void> deleteAllocation(GoalAllocationModel allocation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(goalRepositoryProvider).deleteAllocation(allocation.id));
    ref.invalidate(goalAllocationsStreamProvider(allocation.goalId));
    ref.invalidate(goalDetailProvider(allocation.goalId));
    ref.invalidate(goalsListProvider);
  }
}

final goalControllerProvider = AsyncNotifierProvider<GoalNotifier, void>(GoalNotifier.new);
