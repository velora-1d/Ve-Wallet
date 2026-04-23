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
        .map((data) => data.map((json) => GoalAllocationModel.fromJson(json)).toList());
  }

  @override
  Future<void> addAllocation(GoalAllocationModel allocation) async {
    // We should use a transaction here: insert allocation and update goal's current_amount
    // But since Supabase client doesn't support complex transactions easily from client side
    // (requires RPC or simple sequential calls), we'll do sequential for now.
    // Better: use Supabase Functions or a trigger in the DB.
    
    await _client.from('goal_allocations').insert(allocation.toJson());
    
    // Update goal amount (simplified, better to do in DB)
    final goal = await getGoalById(allocation.goalId);
    await updateGoal(goal.copyWith(currentAmount: goal.currentAmount + allocation.amount));
  }

  @override
  Future<void> deleteAllocation(String id) async {
    // Get allocation first to know the amount and goalId
    final allocationJson = await _client.from('goal_allocations').select().eq('id', id).single();
    final allocation = GoalAllocationModel.fromJson(allocationJson);
    
    await _client.from('goal_allocations').delete().eq('id', id);
    
    // Update goal amount
    final goal = await getGoalById(allocation.goalId);
    await updateGoal(goal.copyWith(currentAmount: goal.currentAmount - allocation.amount));
  }
}
