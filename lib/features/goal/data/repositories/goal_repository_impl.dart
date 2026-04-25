import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/goal_model.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final SupabaseClient _client;

  GoalRepositoryImpl(this._client);

  @override
  Future<List<GoalModel>> getGoals() async {
    final response = await _client.from('goals').select();
    return (response as List).map((json) => GoalModel.fromJson(json)).toList();
  }

  @override
  Stream<List<GoalModel>> watchGoals() {
    return _client
        .from('goals')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => GoalModel.fromJson(json)).toList());
  }

  @override
  Future<GoalModel> getGoalById(String id) async {
    final response = await _client.from('goals').select().eq('id', id).single();
    return GoalModel.fromJson(response);
  }

  @override
  Future<void> addGoal(GoalModel goal) async {
    await _client.from('goals').insert(goal.toJson());
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await _client.from('goals').update(goal.toJson()).eq('id', goal.id);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _client.from('goals').delete().eq('id', id);
  }

  @override
  Future<List<GoalAllocationModel>> getAllocations(String goalId) async {
    final response = await _client
        .from('goal_allocations')
        .select('*, wallets(name)')
        .eq('goal_id', goalId);

    return (response as List).map((json) {
      final walletJson = json['wallets'];
      if (walletJson != null) {
        json['wallet_name'] = walletJson['name'];
      }
      return GoalAllocationModel.fromJson(json);
    }).toList();
  }

  @override
  Stream<List<GoalAllocationModel>> watchAllocations(String goalId) {
    return _client
        .from('goal_allocations')
        .stream(primaryKey: ['id'])
        .eq('goal_id', goalId)
        .map(
          (data) =>
              data.map((json) => GoalAllocationModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> addAllocation(GoalAllocationModel allocation) async {
    await _client.rpc('add_goal_allocation_v1', params: {
      'p_user_id': allocation.userId,
      'p_goal_id': allocation.goalId,
      'p_wallet_id': allocation.walletId,
      'p_amount': allocation.amount,
      'p_date': allocation.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteAllocation(String id) async {
    await _client.rpc('delete_goal_allocation_v1', params: {
      'p_allocation_id': id,
    });
  }
}
