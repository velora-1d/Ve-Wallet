import '../models/goal_model.dart';

abstract class GoalRepository {
  Future<List<GoalModel>> getGoals();
  Stream<List<GoalModel>> watchGoals();
  Future<GoalModel> getGoalById(String id);
  Future<void> addGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  
  // Allocations
  Future<List<GoalAllocationModel>> getAllocations(String goalId);
  Stream<List<GoalAllocationModel>> watchAllocations(String goalId);
  Future<void> addAllocation(GoalAllocationModel allocation);
  Future<void> deleteAllocation(String id);
}
