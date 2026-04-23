import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final SupabaseClient _client;

  BudgetRepositoryImpl(this._client);

  @override
  Future<List<BudgetModel>> getBudgets(int month, int year) async {
    final response = await _client
        .from('budgets')
        .select('*, categories(name)')
        .eq('period_month', month)
        .eq('period_year', year);

    return (response as List).map((json) {
      final categoryJson = json['categories'];
      if (categoryJson != null) {
        json['category_name'] = categoryJson['name'];
      }
      return BudgetModel.fromJson(json);
    }).toList();
  }

  @override
  Stream<List<BudgetModel>> watchBudgets(int month, int year) {
    return _client
        .from('budgets')
        .stream(primaryKey: ['id'])
        .eq('period_year', year)
        .map((data) => data
            .where((json) => json['period_month'] == month)
            .map((json) => BudgetModel.fromJson(json))
            .toList());
    // Note: Stream join is not directly supported in Supabase client, 
    // category_name might be null in stream unless handled specifically or using a view.
  }

  @override
  Future<void> addBudget(BudgetModel budget) async {
    await _client.from('budgets').insert(budget.toJson());
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    await _client.from('budgets').update(budget.toJson()).eq('id', budget.id);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _client.from('budgets').delete().eq('id', id);
  }
}
