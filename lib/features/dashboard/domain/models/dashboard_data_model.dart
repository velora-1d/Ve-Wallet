class DashboardDataModel {
  final bool hasHousehold;
  final String? householdName;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<DashboardChartPoint> expensePoints;
  final List<DashboardGoalPreview> goals;
  final DashboardBudgetAlert? budgetAlert;
  final List<DashboardTransactionPreview> recentTransactions;

  const DashboardDataModel({
    required this.hasHousehold,
    this.householdName,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.expensePoints,
    required this.goals,
    required this.budgetAlert,
    required this.recentTransactions,
  });

  factory DashboardDataModel.empty() {
    return const DashboardDataModel(
      hasHousehold: false,
      householdName: null,
      totalBalance: 0,
      totalIncome: 0,
      totalExpense: 0,
      expensePoints: [],
      goals: [],
      budgetAlert: null,
      recentTransactions: [],
    );
  }
}

class DashboardChartPoint {
  final DateTime date;
  final double amount;

  const DashboardChartPoint({
    required this.date,
    required this.amount,
  });
}

class DashboardGoalPreview {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final double targetAmount;
  final double currentAmount;

  const DashboardGoalPreview({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.targetAmount,
    required this.currentAmount,
  });

  double get progress => targetAmount <= 0 ? 0 : currentAmount / targetAmount;
}

class DashboardBudgetAlert {
  final String categoryName;
  final double spentAmount;
  final double limitAmount;
  final double usageRatio;

  const DashboardBudgetAlert({
    required this.categoryName,
    required this.spentAmount,
    required this.limitAmount,
    required this.usageRatio,
  });
}

class DashboardTransactionPreview {
  final String id;
  final String title;
  final String categoryName;
  final String type;
  final double amount;
  final DateTime date;
  final String walletName;

  const DashboardTransactionPreview({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.date,
    required this.walletName,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isTransfer => type == 'transfer';
}
