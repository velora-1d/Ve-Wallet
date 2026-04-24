import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/budget_provider.dart';
import '../../domain/models/budget_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/domain/models/transaction_model.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final budgetsAsync = ref.watch(budgetsStreamProvider(selectedDate));
    final transactionsAsync = ref.watch(transactionsStreamProvider(null));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Anggaran', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/add-edit-budget'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthPicker(context, ref, selectedDate),
          Expanded(
            child: budgetsAsync.when(
              data: (budgets) {
                if (budgets.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                final transactions = transactionsAsync.value ?? [];
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final spent = _calculateSpent(budget, transactions);
                    final relatedTransactions = _budgetTransactions(
                      budget,
                      transactions,
                    );
                    return _buildBudgetCard(
                      context,
                      budget,
                      spent,
                      relatedTransactions,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = 
                DateTime(selectedDate.year, selectedDate.month - 1);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = 
                DateTime(selectedDate.year, selectedDate.month + 1);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  double _calculateSpent(BudgetModel budget, List<TransactionModel> transactions) {
    return _budgetTransactions(budget, transactions).fold(
      0.0,
      (sum, tx) => sum + tx.amount,
    );
  }

  List<TransactionModel> _budgetTransactions(
    BudgetModel budget,
    List<TransactionModel> transactions,
  ) {
    return transactions
        .where(
          (tx) =>
              tx.categoryId == budget.categoryId &&
              tx.type == TransactionType.expense &&
              tx.date.month == budget.periodMonth &&
              tx.date.year == budget.periodYear,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildBudgetCard(
    BuildContext context,
    BudgetModel budget,
    double spent,
    List<TransactionModel> relatedTransactions,
  ) {
    final progress = budget.amount > 0 ? spent / budget.amount : 0.0;
    final isOverBudget = spent > budget.amount;
    final remaining = budget.amount - spent;
    final isWarning = !isOverBudget && progress >= 0.8;
    final statusText = isOverBudget
        ? 'Melebihi'
        : isWarning
        ? 'Waspada'
        : 'Aman';
    final statusColor = isOverBudget
        ? Colors.red
        : isWarning
        ? Colors.orange
        : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showBudgetDetails(
            context,
            budget,
            spent,
            remaining,
            relatedTransactions,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        budget.categoryName ?? 'Kategori',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          context.push('/add-edit-budget', extra: budget),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isOverBudget
                      ? 'Melebihi ${CurrencyFormatter.format(spent - budget.amount)}'
                      : 'Sisa ${CurrencyFormatter.format(remaining)}',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyFormatter.format(spent)} terpakai',
                      style: const TextStyle(
                        color: AppColors.outline,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'dari ${CurrencyFormatter.format(budget.amount)}',
                      style: const TextStyle(
                        color: AppColors.outline,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget
                          ? Colors.red
                          : isWarning
                          ? Colors.orange
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${relatedTransactions.length} transaksi',
                      style: const TextStyle(
                        color: AppColors.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Tap untuk lihat detail',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showBudgetDetails(
    BuildContext context,
    BudgetModel budget,
    double spent,
    double remaining,
    List<TransactionModel> transactions,
  ) async {
    final monthLabel = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(DateTime(budget.periodYear, budget.periodMonth));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget.categoryName ?? 'Kategori',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  monthLabel,
                  style: const TextStyle(color: AppColors.outline),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailStat(
                        'Limit',
                        CurrencyFormatter.format(budget.amount),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailStat(
                        'Terpakai',
                        CurrencyFormatter.format(spent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailStat(
                        'Sisa',
                        CurrencyFormatter.format(remaining),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Transaksi Terkait',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Belum ada transaksi pada budget ini'),
                  )
                else
                  SizedBox(
                    height: 280,
                    child: ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.surfaceContainer,
                            child: Icon(
                              Icons.receipt_long,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            tx.note.isNotEmpty ? tx.note : tx.categoryName,
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy', 'id_ID').format(tx.date),
                          ),
                          trailing: Text(
                            CurrencyFormatter.format(tx.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.outline),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: AppColors.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada anggaran bulan ini',
            style: TextStyle(color: AppColors.outline, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-edit-budget'),
            icon: const Icon(Icons.add),
            label: const Text('Buat Anggaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
