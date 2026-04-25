import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';

class CategoryReport {
  final String categoryName;
  final double amount;
  final double percentage;
  final int colorValue;

  CategoryReport({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.colorValue,
  });
}

class DailyFlow {
  final DateTime date;
  final double income;
  final double expense;

  DailyFlow({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class ReportDataModel {
  final double totalIncome;
  final double totalExpense;
  final double netFlow;
  final List<CategoryReport> expenseByCategories;
  final List<CategoryReport> incomeByCategories;
  final List<DailyFlow> dailyFlows;
  final List<TransactionModel> topExpenses;
  final List<WalletModel> wallets;

  ReportDataModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netFlow,
    required this.expenseByCategories,
    required this.incomeByCategories,
    required this.dailyFlows,
    required this.topExpenses,
    required this.wallets,
  });

  factory ReportDataModel.empty() {
    return ReportDataModel(
      totalIncome: 0,
      totalExpense: 0,
      netFlow: 0,
      expenseByCategories: [],
      incomeByCategories: [],
      dailyFlows: [],
      topExpenses: [],
      wallets: [],
    );
  }
}
