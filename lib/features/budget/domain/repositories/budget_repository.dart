import '../models/budget_model.dart';

abstract class BudgetRepository {
  Future<List<BudgetModel>> getBudgets(int month, int year);
  Stream<List<BudgetModel>> watchBudgets(int month, int year);
  Future<void> addBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}
