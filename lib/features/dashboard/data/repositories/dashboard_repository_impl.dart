import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/dashboard/domain/models/dashboard_data_model.dart';

class DashboardRepositoryImpl {
  final SupabaseClient _client;

  DashboardRepositoryImpl(this._client);

  Future<DashboardDataModel> getDashboardData() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final householdMember = await _client
        .from('household_members')
        .select('household_id, households(name)')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMember == null) {
      return DashboardDataModel.empty();
    }

    final householdId = householdMember['household_id'] as String;
    final householdName =
        (householdMember['households'] as Map<String, dynamic>?)?['name']
            as String?;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final sevenDayStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));

    final futures = await Future.wait([
      _client
          .from('wallets')
          .select('id, name, balance')
          .eq('household_id', householdId)
          .order('created_at'),
      _client
          .from('transactions')
          .select(
            'id, type, amount, note, date, wallet_id, '
            'wallets(name), categories(name)',
          )
          .eq('household_id', householdId)
          .gte('date', sevenDayStart.toIso8601String().split('T').first)
          .lte('date', monthEnd.toIso8601String().split('T').first)
          .order('date', ascending: false)
          .order('created_at', ascending: false),
      _client
          .from('goals')
          .select(
            'id, name, icon, color, target_amount, current_amount, is_completed',
          )
          .eq('household_id', householdId)
          .eq('is_completed', false)
          .order('created_at', ascending: false)
          .limit(4),
      _client
          .from('budgets')
          .select('amount, category_id, categories(name)')
          .eq('household_id', householdId)
          .eq('period_month', now.month)
          .eq('period_year', now.year),
    ]);

    final wallets = List<Map<String, dynamic>>.from(futures[0] as List);
    final transactions = List<Map<String, dynamic>>.from(futures[1] as List);
    final goals = List<Map<String, dynamic>>.from(futures[2] as List);
    final budgets = List<Map<String, dynamic>>.from(futures[3] as List);

    final totalBalance = wallets.fold<double>(
      0,
      (sum, wallet) => sum + ((wallet['balance'] as num?)?.toDouble() ?? 0),
    );

    double totalIncome = 0;
    double totalExpense = 0;
    final recentTransactions = <DashboardTransactionPreview>[];
    final expenseByDate = <String, double>{};

    for (final tx in transactions) {
      final date = DateTime.parse(tx['date'] as String);
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
      final type = (tx['type'] as String?) ?? 'expense';

      if (!date.isBefore(monthStart) && !date.isAfter(monthEnd)) {
        if (type == 'income') {
          totalIncome += amount;
        } else if (type == 'expense') {
          totalExpense += amount;
        }
      }

      if (!date.isBefore(sevenDayStart) && type == 'expense') {
        final key = date.toIso8601String().split('T').first;
        expenseByDate.update(key, (value) => value + amount, ifAbsent: () => amount);
      }

      if (recentTransactions.length < 5) {
        recentTransactions.add(
          DashboardTransactionPreview(
            id: tx['id'] as String,
            title: ((tx['note'] as String?)?.trim().isNotEmpty ?? false)
                ? (tx['note'] as String).trim()
                : ((((tx['categories'] as Map<String, dynamic>?)?['name']
                            as String?) ??
                        'Transaksi')),
            categoryName:
                ((tx['categories'] as Map<String, dynamic>?)?['name'] as String?) ??
                    'Tanpa Kategori',
            type: type,
            amount: amount,
            date: date,
            walletName:
                ((tx['wallets'] as Map<String, dynamic>?)?['name'] as String?) ??
                    'Dompet',
          ),
        );
      }
    }

    final expensePoints = List.generate(7, (index) {
      final date = DateTime(
        sevenDayStart.year,
        sevenDayStart.month,
        sevenDayStart.day + index,
      );
      final key = date.toIso8601String().split('T').first;
      return DashboardChartPoint(
        date: date,
        amount: expenseByDate[key] ?? 0,
      );
    });

    final goalPreviews = goals
        .map(
          (goal) => DashboardGoalPreview(
            id: goal['id'] as String,
            name: (goal['name'] as String?) ?? 'Goal',
            icon: (goal['icon'] as String?) ?? 'savings',
            colorHex: (goal['color'] as String?) ?? '#2563EB',
            targetAmount: (goal['target_amount'] as num?)?.toDouble() ?? 0,
            currentAmount: (goal['current_amount'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    DashboardBudgetAlert? budgetAlert;
    var highestUsage = 0.0;
    for (final budget in budgets) {
      final categoryName =
          ((budget['categories'] as Map<String, dynamic>?)?['name'] as String?) ??
              'Kategori';
      final categorySpending = transactions
          .where(
            (tx) =>
                ((tx['categories'] as Map<String, dynamic>?)?['name'] as String?) ==
                    categoryName &&
                (tx['type'] as String?) == 'expense' &&
                !DateTime.parse(tx['date'] as String).isBefore(monthStart),
          )
          .fold<double>(
            0,
            (sum, tx) => sum + ((tx['amount'] as num?)?.toDouble() ?? 0),
          );

      final limit = (budget['amount'] as num?)?.toDouble() ?? 0.0;
      final double usage = limit <= 0 ? 0.0 : categorySpending / limit;

      if (usage > highestUsage) {
        highestUsage = usage;
        budgetAlert = DashboardBudgetAlert(
          categoryName: categoryName,
          spentAmount: categorySpending,
          limitAmount: limit,
          usageRatio: usage,
        );
      }
    }

    if (budgetAlert != null && budgetAlert.usageRatio < 0.5) {
      budgetAlert = null;
    }

    return DashboardDataModel(
      hasHousehold: true,
      householdName: householdName,
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      expensePoints: expensePoints,
      goals: goalPreviews,
      budgetAlert: budgetAlert,
      recentTransactions: recentTransactions,
    );
  }
}
