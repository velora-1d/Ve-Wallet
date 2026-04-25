import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import '../../domain/models/report_data_model.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final SupabaseClient _client;

  ReportRepositoryImpl(this._client);

  @override
  Future<ReportDataModel> getReportData({
    required DateTime startDate,
    required DateTime endDate,
    String? walletId,
  }) async {
    // 1. Fetch transactions in range
    var query = _client.from('transactions').select();
    
    query = query.gte('date', startDate.toIso8601String());
    query = query.lte('date', endDate.toIso8601String());
    
    if (walletId != null) {
      query = query.eq('wallet_id', walletId);
    }

    final txResponse = await query;
    final transactions = (txResponse as List).map((json) => TransactionModel.fromJson(json)).toList();

    // 2. Fetch categories to get colors
    final catResponse = await _client.from('categories').select();
    final categories = (catResponse as List).map((json) => CategoryModel.fromJson(json)).toList();
    final categoryMap = {for (var cat in categories) cat.id: cat};

    // 3. Fetch wallets used for export metadata and balance summary.
    var walletQuery = _client.from('wallets').select();
    if (walletId != null) {
      walletQuery = walletQuery.eq('id', walletId);
    }
    final walletResponse = await walletQuery;
    final wallets = (walletResponse as List)
        .map((json) => WalletModel.fromJson(json))
        .toList();

    // 4. Aggregate Data
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> expenseByCat = {};
    Map<String, double> incomeByCat = {};
    Map<String, DailyFlow> flowByDate = {};

    // Initialize flowByDate with all days in range to avoid gaps in chart
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day);
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      flowByDate[current.toIso8601String()] = DailyFlow(date: current, income: 0, expense: 0);
      current = current.add(const Duration(days: 1));
    }

    for (var tx in transactions) {
      if (tx.isTransfer) {
        continue;
      }

      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final keyStr = dateKey.toIso8601String();
      
      if (!flowByDate.containsKey(keyStr)) {
        flowByDate[keyStr] = DailyFlow(date: dateKey, income: 0, expense: 0);
      }

      final currentFlow = flowByDate[keyStr]!;

      if (tx.isIncome) {
        totalIncome += tx.amount;
        incomeByCat[tx.categoryId] = (incomeByCat[tx.categoryId] ?? 0) + tx.amount;
        flowByDate[keyStr] = DailyFlow(
          date: dateKey, 
          income: currentFlow.income + tx.amount, 
          expense: currentFlow.expense
        );
      } else {
        totalExpense += tx.amount;
        expenseByCat[tx.categoryId] = (expenseByCat[tx.categoryId] ?? 0) + tx.amount;
        flowByDate[keyStr] = DailyFlow(
          date: dateKey, 
          income: currentFlow.income, 
          expense: currentFlow.expense + tx.amount
        );
      }
    }

    // Sort daily flows by date
    final dailyFlowList = flowByDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    // Process Category Reports
    List<CategoryReport> expenseReports = [];
    expenseByCat.forEach((catId, amount) {
      final cat = categoryMap[catId];
      expenseReports.add(CategoryReport(
        categoryName: cat?.name ?? 'Lainnya',
        amount: amount,
        percentage: totalExpense > 0 ? (amount / totalExpense) * 100 : 0,
        colorValue: cat?.color ?? 0xFF9E9E9E,
      ));
    });
    expenseReports.sort((a, b) => b.amount.compareTo(a.amount));

    List<CategoryReport> incomeReports = [];
    incomeByCat.forEach((catId, amount) {
      final cat = categoryMap[catId];
      incomeReports.add(CategoryReport(
        categoryName: cat?.name ?? 'Lainnya',
        amount: amount,
        percentage: totalIncome > 0 ? (amount / totalIncome) * 100 : 0,
        colorValue: cat?.color ?? 0xFF9E9E9E,
      ));
    });
    incomeReports.sort((a, b) => b.amount.compareTo(a.amount));

    // Top Expenses
    final topExpenses = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    final top5Expenses = topExpenses.take(5).toList();

    return ReportDataModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netFlow: totalIncome - totalExpense,
      expenseByCategories: expenseReports,
      incomeByCategories: incomeReports,
      dailyFlows: dailyFlowList,
      topExpenses: top5Expenses,
      wallets: wallets,
    );
  }
}
