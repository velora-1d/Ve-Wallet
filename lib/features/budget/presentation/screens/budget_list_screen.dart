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
                    return _buildBudgetCard(context, budget, spent);
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
    return transactions
        .where((tx) => 
            tx.categoryId == budget.categoryId && 
            tx.type == TransactionType.expense &&
            tx.date.month == budget.periodMonth &&
            tx.date.year == budget.periodYear)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Widget _buildBudgetCard(BuildContext context, BudgetModel budget, double spent) {
    final progress = budget.amount > 0 ? spent / budget.amount : 0.0;
    final isOverBudget = spent > budget.amount;
    final remaining = budget.amount - spent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: () => context.push('/add-edit-budget', extra: budget),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.categoryName ?? 'Kategori',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isOverBudget 
                    ? 'Over budget!' 
                    : 'Sisa ${CurrencyFormatter.format(remaining)}',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyFormatter.format(spent)} terpakai',
                  style: const TextStyle(color: AppColors.outline, fontSize: 13),
                ),
                Text(
                  'dari ${CurrencyFormatter.format(budget.amount)}',
                  style: const TextStyle(color: AppColors.outline, fontSize: 13),
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
                  isOverBudget ? Colors.red : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
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
