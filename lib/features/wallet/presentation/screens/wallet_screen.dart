import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/currency_formatter.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
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
            
            // Placeholder: Anggaran Bulan Ini
            _buildSectionHeader(title: 'Anggaran Bulan Ini'),
            const SizedBox(height: 12),
            _buildBudgetList(),
            
            const SizedBox(height: 24),
            
            // Placeholder: Target Tabungan
            _buildSectionHeader(title: 'Target Tabungan'),
            const SizedBox(height: 12),
            _buildGoalsList(),
            
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

  Widget _buildWalletCards(BuildContext context, List wallets) {
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
            icon: Icons.account_balance, // Could dynamically parse from wallet.icon
            label: wallet.name,
            amount: CurrencyFormatter.format(wallet.balance),
            isActive: index == 0, // Highlight the first one as default for now
            bgColor: Color(wallet.color).withValues(alpha: 0.2), // Dynamic background based on color
            iconColor: Color(wallet.color),
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildWalletCard({
    required IconData icon,
    required String label,
    required String amount,
    required bool isActive,
    required Color bgColor,
    required Color iconColor,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => context.push('/wallet-detail'),
      child: Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? const Border(left: BorderSide(color: AppColors.primaryContainer, width: 4))
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
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
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
        border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.none),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.none),
        ),
        child: OutlinedButton(
          onPressed: () => context.push('/add-wallet'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: const BorderSide(color: AppColors.outlineVariant, style: BorderStyle.solid),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.outline),
              Text('Tambah', style: TextStyle(fontSize: 12, color: AppColors.outline)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          _buildBudgetItem(
            icon: Icons.shopping_cart,
            label: 'Belanja Bulanan',
            spent: 1200000,
            total: 3000000,
            color: AppColors.primaryContainer,
          ),
          const Divider(height: 1),
          _buildBudgetItem(
            icon: Icons.restaurant,
            label: 'Makan & Minum',
            spent: 1800000,
            total: 2000000,
            color: AppColors.secondaryContainer,
          ),
          const Divider(height: 1),
          _buildBudgetItem(
            icon: Icons.local_gas_station,
            label: 'Transportasi',
            spent: 600000,
            total: 500000,
            color: AppColors.error,
            isOverBudget: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem({
    required IconData icon,
    required String label,
    required double spent,
    required double total,
    required Color color,
    bool isOverBudget = false,
  }) {
    final progress = (spent / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                ],
              ),
              Text(
                '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(total)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverBudget ? AppColors.error : AppColors.onSurfaceVariant,
                  fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildGoalCard(
            icon: Icons.flight_takeoff,
            label: 'Liburan Jepang',
            deadline: '15 Des 2024',
            saved: 12000000,
            target: 20000000,
            iconBg: const Color(0xFFDBE1FF),
            iconColor: AppColors.primaryContainer,
          ),
          const SizedBox(height: 16),
          _buildGoalCard(
            icon: Icons.home,
            label: 'DP Rumah',
            deadline: '1 Jan 2026',
            saved: 50000000,
            target: 200000000,
            iconBg: AppColors.surfaceVariant,
            iconColor: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String label,
    required String deadline,
    required double saved,
    required double target,
    required Color iconBg,
    required Color iconColor,
  }) {
    final progress = (saved / target).clamp(0.0, 1.0);
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      Text(
                        'Tenggat: $deadline',
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: AppColors.secondaryContainer),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Alokasi Dana',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkumpul ${CurrencyFormatter.format(saved)} dari ${CurrencyFormatter.format(target)}',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
