import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/currency_formatter.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/features/budget/presentation/providers/budget_provider.dart';
import 'package:ve_wallet/features/goal/presentation/providers/goal_provider.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final now = DateTime.now();
    final budgetsAsync = ref.watch(
      budgetsStreamProvider(DateTime(now.year, now.month)),
    );
    final goalsAsync = ref.watch(goalsStreamProvider);

    double totalBalance = 0;
    walletsAsync.whenData((wallets) {
      for (var w in wallets) {
        totalBalance += w.balance;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.push('/settings'),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Dompet',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryContainer),
            onPressed: () => context.push('/add-wallet'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceVariant, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Akun & Sumber Dana
            _buildSectionHeader(
              title: 'Akun & Sumber Dana',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalBalance),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            walletsAsync.when(
              data: (wallets) => _buildWalletCards(context, wallets),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(title: 'Anggaran Bulan Ini'),
            const SizedBox(height: 12),
            budgetsAsync.when(
              data: (budgets) => _buildBudgetSummary(context, budgets),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader(title: 'Target Tabungan'),
            const SizedBox(height: 12),
            goalsAsync.when(
              data: (goals) => _buildGoalsSummary(context, goals),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),

            const SizedBox(height: 100), // Bottom padding for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildWalletCards(BuildContext context, List<dynamic> wallets) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: wallets.length + 1, // +1 for the Add button
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == wallets.length) {
            return _buildAddWalletCard(context);
          }
          final wallet = wallets[index];
          return _buildWalletCard(
            wallet: wallet,
            label: wallet.name,
            amount: CurrencyFormatter.format(wallet.balance),
            isActive: index == 0, // Highlight the first one as default for now
            bgColor: Color(wallet.color).withValues(alpha: 0.2),
            iconColor: Color(wallet.color),
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildWalletCard({
    required dynamic wallet,
    required String label,
    required String amount,
    required bool isActive,
    required Color bgColor,
    required Color iconColor,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => context.push('/wallet-detail', extra: wallet),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.primaryContainer, width: 4),
                )
              : null,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    WalletIconUtils.getIcon(wallet.icon),
                    color: iconColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWalletCard(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.none,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outlineVariant,
            style: BorderStyle.none,
          ),
        ),
        child: OutlinedButton(
          onPressed: () => context.push('/add-wallet'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(
              color: AppColors.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.outline),
              Text(
                'Tambah',
                style: TextStyle(fontSize: 12, color: AppColors.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(BuildContext context, List<dynamic> budgets) {
    if (budgets.isEmpty) {
      return _buildModuleEntryCard(
        title: 'Belum ada anggaran bulan ini',
        subtitle: 'Buat budget pertama Anda untuk mulai memantau pengeluaran.',
        buttonLabel: 'Buka Budget',
        onTap: () => context.push('/budget-list'),
      );
    }

    return _buildModuleEntryCard(
      title: '${budgets.length} budget aktif',
      subtitle: 'Kelola limit pengeluaran per kategori dari satu tempat.',
      buttonLabel: 'Kelola Budget',
      onTap: () => context.push('/budget-list'),
    );
  }

  Widget _buildGoalsSummary(BuildContext context, List<dynamic> goals) {
    if (goals.isEmpty) {
      return _buildModuleEntryCard(
        title: 'Belum ada target tabungan',
        subtitle: 'Tambahkan goal untuk melacak progres tabungan Anda.',
        buttonLabel: 'Buka Goals',
        onTap: () => context.push('/goal-list'),
      );
    }

    final activeGoals = goals.where((goal) => goal.progress < 1.0).length;
    return _buildModuleEntryCard(
      title: '${goals.length} goal tersimpan',
      subtitle: '$activeGoals goal masih aktif dan bisa Anda lanjutkan.',
      buttonLabel: 'Kelola Goals',
      onTap: () => context.push('/goal-list'),
    );
  }

  Widget _buildModuleEntryCard({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryContainer),
                foregroundColor: AppColors.primaryContainer,
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
