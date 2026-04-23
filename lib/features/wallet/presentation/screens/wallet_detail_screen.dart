import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class WalletDetailScreen extends ConsumerWidget {
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final transactionsAsync = ref.watch(transactionsStreamProvider(wallet.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Header with Balance
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Color(wallet.color),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => context.push(
                  '/add-wallet',
                  extra: {'isEdit': true, 'wallet': wallet},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _showDeleteConfirmation(context, ref),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(wallet.color),
                      Color(wallet.color).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        WalletIconUtils.getIcon(wallet.icon),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      wallet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(wallet.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Statistics Row
          transactionsAsync.when(
            data: (transactions) {
              final income = transactions
                  .where((tx) => tx.isIncome)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              final expense = transactions
                  .where((tx) => tx.isExpense)
                  .fold(0.0, (sum, tx) => sum + tx.amount);

              return SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard(
                        context,
                        title: 'Pemasukan',
                        amount: income,
                        icon: Icons.arrow_downward,
                        iconColor: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        title: 'Pengeluaran',
                        amount: expense,
                        icon: Icons.arrow_upward,
                        iconColor: AppColors.error,
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
            error: (err, _) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('Belum ada transaksi di dompet ini'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tx = transactions[index];
                  return _buildTransactionItem(context, tx);
                }, childCount: transactions.length),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/add-transaction', extra: {'walletId': wallet.id}),
        backgroundColor: Color(wallet.color),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(amount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx) {
    final isExpense = tx.isExpense;
    final isTransfer = tx.isTransfer;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'id_ID');

    return InkWell(
      onTap: () => context.push('/transaction-detail', extra: tx),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isTransfer
                    ? Icons.swap_horiz
                    : isExpense
                    ? Icons.shopping_bag
                    : Icons.payments,
                color: isTransfer
                    ? AppColors.primary
                    : isExpense
                    ? AppColors.error
                    : AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTransfer ? 'Transfer' : tx.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormat.format(tx.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isTransfer
                  ? currencyFormat.format(tx.amount)
                  : (isExpense ? '-' : '+') + currencyFormat.format(tx.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTransfer
                    ? AppColors.primary
                    : isExpense
                    ? AppColors.error
                    : AppColors.success,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    if (wallet.balance != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dompet hanya bisa dihapus jika saldo = 0'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Dompet?'),
        content: const Text(
          'Seluruh riwayat transaksi di dompet ini juga akan terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(walletRepositoryProvider)
                    .deleteWallet(wallet.id);
                if (context.mounted) {
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus dompet: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
