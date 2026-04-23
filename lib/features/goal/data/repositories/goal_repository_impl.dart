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
    final walletJson = await _client
        .from('wallets')
        .select('balance')
        .eq('id', allocation.walletId)
        .single();
    final walletBalance = (walletJson['balance'] as num).toDouble();
    if (walletBalance < allocation.amount) {
      throw Exception('Saldo dompet tidak mencukupi untuk alokasi');
    }

    await _client
        .from('wallets')
        .update({'balance': walletBalance - allocation.amount})
        .eq('id', allocation.walletId);

    await _client.from('goal_allocations').insert(allocation.toJson());

    final goal = await getGoalById(allocation.goalId);
    final updatedAmount = goal.currentAmount + allocation.amount;
    await updateGoal(
      goal.copyWith(
        currentAmount: updatedAmount,
        isCompleted: updatedAmount >= goal.targetAmount,
      ),
    );
  }

  @override
  Future<void> deleteAllocation(String id) async {
    final allocationJson = await _client
        .from('goal_allocations')
        .select()
        .eq('id', id)
        .single();
    final allocation = GoalAllocationModel.fromJson(allocationJson);

    final walletJson = await _client
        .from('wallets')
        .select('balance')
        .eq('id', allocation.walletId)
        .single();
    final walletBalance = (walletJson['balance'] as num).toDouble();
    await _client
        .from('wallets')
        .update({'balance': walletBalance + allocation.amount})
        .eq('id', allocation.walletId);

    await _client.from('goal_allocations').delete().eq('id', id);

    final goal = await getGoalById(allocation.goalId);
    final updatedAmount = goal.currentAmount - allocation.amount;
    await updateGoal(
      goal.copyWith(
        currentAmount: updatedAmount < 0 ? 0 : updatedAmount,
        isCompleted: false,
      ),
    );
  }
}
