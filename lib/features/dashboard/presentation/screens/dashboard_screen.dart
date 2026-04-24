import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/currency_formatter.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/budget/presentation/providers/budget_provider.dart';
import 'package:ve_wallet/features/goal/presentation/providers/goal_provider.dart';
import 'package:ve_wallet/features/goal/domain/models/goal_model.dart';
import 'package:ve_wallet/features/budget/domain/models/budget_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider(null));
    final goalsAsync = ref.watch(goalsStreamProvider);
    final now = DateTime.now();
    final budgetsAsync = ref.watch(
      budgetsStreamProvider(DateTime(now.year, now.month)),
    );

    // Calculate totals
    double totalBalance = 0;
    double totalIncome = 0;
    double totalExpense = 0;

    final wallets = walletsAsync.value;
    if (wallets != null) {
      for (var wallet in wallets) {
        totalBalance += wallet.balance;
      }
    }

    final transactions = transactionsAsync.value;
    if (transactions != null) {
      final currentMonth = now.month;
      final currentYear = now.year;

      for (var tx in transactions) {
        if (tx.date.month == currentMonth && tx.date.year == currentYear) {
          if (tx.isIncome) {
            totalIncome += tx.amount;
          } else if (tx.isExpense) {
            totalExpense += tx.amount;
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              elevation: 0,
              centerTitle: true,
              leadingWidth: 64,
              leading: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBbh3gAOTLPt1TqjQq8vaskm5aDjbEdvBAjz96LvBnWAhaVhNasOw1ql-2DxSjwUotFPduC3AkWhs6ogYZz0VaL9kcQfItEN1F0_N6YQpaNeyyK55R6kU_6Nq7VqRb7mt1j0-i0_TLew3uG6d9dh6IGhCIS8VZhiFQInMeBN93CFwQO1KIwQUabKWFSiD9SDS98lboCcBDgQ8QzmzNcO2PZ0ee8HYtMtEq7agSbxo9hFUM9hYXZ60yMIpxpDBTJVAcJntiw4ZyqctP5',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              'Ve',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                'Ve-Wallet',
                style: GoogleFonts.inter(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.push('/notifications'),
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.outline,
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 84), // Adjust for fixed AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card
                  _buildBalanceCard(totalBalance, totalIncome, totalExpense),
                  const SizedBox(height: 24),

                  // Expense Chart
                  _buildExpenseChart(context, transactions ?? const []),
                  const SizedBox(height: 24),

                  // Savings Goals
                  goalsAsync.when(
                    data: (goals) => _buildSavingsGoals(context, goals),
                    loading: () => const SizedBox(),
                    error: (error, stack) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),

                  // Budget Alert
                  budgetsAsync.when(
                    data: (budgets) =>
                        _buildBudgetAlert(context, budgets, transactions ?? []),
                    loading: () => const SizedBox(),
                    error: (error, stack) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  transactionsAsync.when(
                    data: (transactions) =>
                        _buildRecentTransactions(context, transactions),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4F9C), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total Saldo',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.visibility_outlined,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(balance),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildBalanceSummary(
                icon: Icons.arrow_upward,
                color: Colors.greenAccent,
                label: '${CurrencyFormatter.formatCompact(income)} Masuk',
              ),
              const SizedBox(width: 8),
              _buildBalanceSummary(
                icon: Icons.arrow_downward,
                color: Colors.redAccent,
                label: '${CurrencyFormatter.formatCompact(expense)} Keluar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      final total = transactions
          .where(
            (tx) =>
                tx.isExpense &&
                tx.date.year == date.year &&
                tx.date.month == date.month &&
                tx.date.day == date.day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);
      return (date: date, total: total);
    });

    final maxTotal = last7Days.fold<double>(
      0,
      (max, item) => item.total > max ? item.total : max,
    );
    final double maxY = maxTotal == 0 ? 100.0 : maxTotal * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengeluaran 7 Hari',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= last7Days.length) {
                        return const SizedBox();
                      }
                      final date = last7Days[index].date;
                      final isHighlight = index == last7Days.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('E', 'id_ID').format(date),
                          style: GoogleFonts.inter(
                            color: isHighlight
                                ? AppColors.onBackground
                                : AppColors.outline,
                            fontSize: 12,
                            fontWeight: isHighlight
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(last7Days.length, (index) {
                final item = last7Days[index];
                return _buildBarGroup(
                  index,
                  item.total,
                  color: index == last7Days.length - 1
                      ? AppColors.secondaryContainer
                      : AppColors.primaryFixedDim,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(
    int x,
    double y, {
    Color color = AppColors.primaryFixedDim,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16, // Thinner bars like in design
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ],
    );
  }

  Widget _buildSavingsGoals(BuildContext context, List<GoalModel> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target Tabungan',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/goal-list'),
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (goals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Belum ada target tabungan',
              style: GoogleFonts.inter(color: AppColors.outline, fontSize: 14),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 110,
            ),
            itemCount: goals.length > 2 ? 2 : goals.length,
            itemBuilder: (context, index) =>
                _buildGoalCard(context: context, goal: goals[index]),
          ),
      ],
    );
  }

  Widget _buildGoalCard({
    required BuildContext context,
    required GoalModel goal,
  }) {
    final progress = goal.progress;

    return InkWell(
      onTap: () => context.push('/goal-detail/${goal.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(goal.icon),
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              goal.name,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.onBackground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress > 1.0 ? 1.0 : progress,
                backgroundColor: AppColors.surfaceContainer,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flight':
        return Icons.flight_takeoff;
      case 'laptop':
        return Icons.laptop_mac;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.star;
    }
  }

  Widget _buildBudgetAlert(
    BuildContext context,
    List<BudgetModel> budgets,
    List<TransactionModel> transactions,
  ) {
    if (budgets.isEmpty) return const SizedBox();

    // Find budget with highest usage percentage
    BudgetModel? criticalBudget;
    double maxUsage = 0;

    for (var budget in budgets) {
      final spent = transactions
          .where(
            (tx) =>
                tx.categoryId == budget.categoryId &&
                tx.type == TransactionType.expense &&
                tx.date.month == budget.periodMonth &&
                tx.date.year == budget.periodYear,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final usage = budget.amount > 0 ? spent / budget.amount : 0.0;
      if (usage > maxUsage) {
        maxUsage = usage;
        criticalBudget = budget;
      }
    }

    if (criticalBudget == null || maxUsage < 0.5) return const SizedBox();

    final isOver = maxUsage >= 1.0;

    return InkWell(
      onTap: () => context.push('/budget-list'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOver ? AppColors.errorContainer : AppColors.secondaryFixed,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOver ? AppColors.error : AppColors.secondaryFixedDim,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOver ? Icons.error_outline : Icons.warning_amber_rounded,
                  color: isOver
                      ? AppColors.error
                      : AppColors.secondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOver
                        ? 'Anggaran ${criticalBudget.categoryName} terlampaui!'
                        : 'Anggaran ${criticalBudget.categoryName} ${(maxUsage * 100).toInt()}% terpakai',
                    style: GoogleFonts.inter(
                      color: isOver
                          ? AppColors.error
                          : AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: maxUsage > 1.0 ? 1.0 : maxUsage,
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver ? AppColors.error : AppColors.secondaryContainer,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terakhir',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/transactions'),
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Belum ada transaksi',
              style: GoogleFonts.inter(color: AppColors.outline, fontSize: 14),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.surfaceContainerHigh,
                indent: 64,
              ),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.isIncome;
                final isTransfer = tx.isTransfer;

                IconData iconData = isTransfer
                    ? Icons.swap_horiz
                    : _getTransactionIcon(tx.categoryName, isIncome);
                Color iconColor = isTransfer
                    ? AppColors.primary
                    : isIncome
                    ? AppColors.onPrimaryFixedVariant
                    : AppColors.secondary;
                Color bgColor = isTransfer
                    ? AppColors.primaryFixed
                    : isIncome
                    ? AppColors.primaryFixedDim
                    : AppColors.secondaryFixed;

                return _buildTransactionItem(
                  icon: iconData,
                  iconColor: iconColor,
                  bgColor: bgColor,
                  title: tx.note.isNotEmpty ? tx.note : tx.categoryName,
                  subtitle: _formatTransactionDate(tx.date),
                  amount: isTransfer
                      ? CurrencyFormatter.format(tx.amount)
                      : '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(tx.amount)}',
                  amountColor: isTransfer
                      ? AppColors.primary
                      : isIncome
                      ? AppColors.primary
                      : AppColors.error,
                  onTap: () => context.push('/transaction-detail', extra: tx),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _getTransactionIcon(String category, bool isIncome) {
    if (isIncome) return Icons.work_outline;
    final cat = category.toLowerCase();
    if (cat.contains('makan') || cat.contains('food')) return Icons.restaurant;
    if (cat.contains('transport') || cat.contains('bensin')) {
      return Icons.directions_car_outlined;
    }
    if (cat.contains('belanja') || cat.contains('shop')) {
      return Icons.shopping_bag_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) {
      return 'Hari ini, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) {
      return 'Kemarin, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day} ${_getMonthName(date.month)}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.onBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
