import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: const CachedNetworkImageProvider(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBbh3gAOTLPt1TqjQq8vaskm5aDjbEdvBAjz96LvBnWAhaVhNasOw1ql-2DxSjwUotFPduC3AkWhs6ogYZz0VaL9kcQfItEN1F0_N6YQpaNeyyK55R6kU_6Nq7VqRb7mt1j0-i0_TLew3uG6d9dh6IGhCIS8VZhiFQInMeBN93CFwQO1KIwQUabKWFSiD9SDS98lboCcBDgQ8QzmzNcO2PZ0ee8HYtMtEq7agSbxo9hFUM9hYXZ60yMIpxpDBTJVAcJntiw4ZyqctP5',
            ),
          ),
        ),
        title: const Text(
          'Ve-Wallet',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: AppColors.outline),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            _buildBalanceCard(),
            const SizedBox(height: 24),
            // Expense Chart
            _buildExpenseChart(context),
            const SizedBox(height: 24),
            // Savings Goals
            _buildSavingsGoals(context),
            const SizedBox(height: 24),
            // Budget Alert
            _buildBudgetAlert(),
            const SizedBox(height: 24),
            // Recent Transactions
            _buildRecentTransactions(context),
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
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
            color: const Color(0xFF2563EB).withOpacity(0.2),
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
              const Text(
                'Total Saldo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.visibility_outlined, color: Colors.white.withOpacity(0.7), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Rp 12.450.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildBalanceSummary(
                icon: Icons.arrow_upward,
                color: Colors.greenAccent,
                label: 'Rp 8.000.000 Masuk',
              ),
              const SizedBox(width: 8),
              _buildBalanceSummary(
                icon: Icons.arrow_downward,
                color: Colors.redAccent,
                label: 'Rp 3.412.000 Keluar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary({required IconData icon, required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengeluaran 7 Hari',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt()],
                          style: const TextStyle(color: AppColors.outline, fontSize: 12),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBarGroup(0, 30),
                _buildBarGroup(1, 50),
                _buildBarGroup(2, 40),
                _buildBarGroup(3, 90, color: AppColors.secondaryContainer),
                _buildBarGroup(4, 60),
                _buildBarGroup(5, 20),
                _buildBarGroup(6, 35),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, {Color color = AppColors.primaryFixedDim}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildSavingsGoals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Target Tabungan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildGoalCard(
                icon: Icons.flight_takeoff,
                title: 'Liburan Bali',
                progress: 0.65,
                progressColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGoalCard(
                icon: Icons.laptop_mac,
                title: 'Macbook Pro',
                progress: 0.3,
                progressColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryFixedDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.secondaryContainer, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Budget Makanan 82% terpakai',
                style: TextStyle(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.82,
              backgroundColor: Colors.white50,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryContainer),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTransactionItem(
                icon: Icons.restaurant,
                iconColor: AppColors.secondary,
                bgColor: AppColors.secondaryFixed,
                title: 'Makan Siang Kopi Kenangan',
                subtitle: 'Hari ini, 12:30',
                amount: '- Rp 45.000',
                amountColor: AppColors.error,
              ),
              const Divider(height: 1, color: AppColors.surfaceContainerHigh),
              _buildTransactionItem(
                icon: Icons.work,
                iconColor: AppColors.onPrimaryFixedVariant,
                bgColor: AppColors.primaryFixedDim,
                title: 'Gaji Bulan April',
                subtitle: 'Kemarin, 09:00',
                amount: '+ Rp 8.000.000',
                amountColor: AppColors.primary,
              ),
              const Divider(height: 1, color: AppColors.surfaceContainerHigh),
              _buildTransactionItem(
                icon: Icons.directions_car,
                iconColor: AppColors.onSurfaceVariant,
                bgColor: AppColors.surfaceVariant,
                title: 'Isi Bensin Pertamax',
                subtitle: '15 April, 18:45',
                amount: '- Rp 150.000',
                amountColor: AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onBackground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.outline, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: amountColor),
          ),
        ],
      ),
    );
  }
}
