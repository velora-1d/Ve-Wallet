import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/currency_formatter.dart';
import 'package:ve_wallet/features/dashboard/domain/models/dashboard_data_model.dart';
import 'package:ve_wallet/features/dashboard/presentation/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.push('/settings'),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(dashboardDataProvider),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF334155)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
          await ref.read(dashboardDataProvider.future);
        },
        child: dashboardAsync.when(
          data: (data) => _DashboardContent(data: data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _DashboardError(
            message: error.toString(),
            onRetry: () => ref.invalidate(dashboardDataProvider),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardDataModel data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.hasHousehold) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _HeroCard(
            title: 'Dashboard belum punya data',
            subtitle:
                'Saat ini akun kamu belum terhubung ke shared account. Buat shared account dulu atau gabung pakai kode invite supaya data keuangan bisa muncul di dashboard.',
          ),
          const SizedBox(height: 18),
          _EmptyStateCard(
            title: 'Belum terhubung ke household',
            description:
                'Semua wallet, transaksi, budget, dan goals mengambil data berdasarkan shared account aktif.',
            buttonLabel: 'Buka Shared Account',
            onTap: () => context.push('/shared-account'),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        _HeroCard(
          title: data.householdName ?? 'Ve-Wallet',
          subtitle:
              'Ringkasan keuangan household aktif kamu. Semua angka di halaman ini menampilkan data terbaru aplikasi.',
        ),
        const SizedBox(height: 18),
        _SummaryCard(data: data),
        const SizedBox(height: 18),
        _SectionTitle(
          title: 'Pengeluaran 7 Hari',
          actionLabel: 'Transaksi',
          onTap: () => context.push('/transactions'),
        ),
        const SizedBox(height: 12),
        _ExpenseChartCard(points: data.expensePoints),
        const SizedBox(height: 18),
        _SectionTitle(
          title: 'Target Tabungan',
          actionLabel: 'Kelola',
          onTap: () => context.push('/goal-list'),
        ),
        const SizedBox(height: 12),
        _GoalsCard(goals: data.goals),
        if (data.budgetAlert != null) ...[
          const SizedBox(height: 18),
          _BudgetAlertCard(alert: data.budgetAlert!),
        ],
        const SizedBox(height: 18),
        _SectionTitle(
          title: 'Transaksi Terbaru',
          actionLabel: 'Lihat semua',
          onTap: () => context.push('/transactions'),
        ),
        const SizedBox(height: 12),
        _RecentTransactionsCard(transactions: data.recentTransactions),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.space_dashboard_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DashboardDataModel data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total saldo household',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(data.totalBalance),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Masuk bulan ini',
                  value: CurrencyFormatter.formatCompact(data.totalIncome),
                  icon: Icons.south_west_rounded,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatPill(
                  label: 'Keluar bulan ini',
                  value: CurrencyFormatter.formatCompact(data.totalExpense),
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseChartCard extends StatelessWidget {
  final List<DashboardChartPoint> points;

  const _ExpenseChartCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final chartPoints = points.isEmpty
        ? List.generate(
            7,
            (index) => DashboardChartPoint(
              date: DateTime.now().subtract(Duration(days: 6 - index)),
              amount: 0,
            ),
          )
        : points;

    final maxY = math.max<double>(
      100000,
      chartPoints.fold<double>(
            0,
            (maxValue, point) => math.max(maxValue, point.amount),
          ) *
          1.25,
    );

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= chartPoints.length) {
                    return const SizedBox.shrink();
                  }
                  final labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[chartPoints[index].date.weekday - 1],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(chartPoints.length, (index) {
            final point = chartPoints[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: point.amount,
                  width: 16,
                  borderRadius: BorderRadius.circular(99),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF93C5FD), Color(0xFF2563EB)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  final List<DashboardGoalPreview> goals;

  const _GoalsCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const _SimpleEmptyCard(
        title: 'Belum ada target tabungan',
        description: 'Tambahkan goals supaya progres tabungan bisa tampil di dashboard.',
      );
    }

    return Column(
      children: goals
          .map(
            (goal) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _parseHexColor(goal.colorHex).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _iconFromName(goal.icon),
                          color: _parseHexColor(goal.colorHex),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goal.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '${(goal.progress * 100).clamp(0, 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _parseHexColor(goal.colorHex),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: goal.progress.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _parseHexColor(goal.colorHex),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${CurrencyFormatter.format(goal.currentAmount)} dari ${CurrencyFormatter.format(goal.targetAmount)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BudgetAlertCard extends StatelessWidget {
  final DashboardBudgetAlert alert;

  const _BudgetAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isOver = alert.usageRatio >= 1;
    final accent = isOver ? const Color(0xFFDC2626) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isOver
                      ? 'Budget ${alert.categoryName} sudah terlampaui'
                      : 'Budget ${alert.categoryName} hampir penuh',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: alert.usageRatio.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${CurrencyFormatter.format(alert.spentAmount)} dari ${CurrencyFormatter.format(alert.limitAmount)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final List<DashboardTransactionPreview> transactions;

  const _RecentTransactionsCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _SimpleEmptyCard(
        title: 'Belum ada transaksi',
        description: 'Saat transaksi pertama masuk, daftar terbaru akan tampil di sini.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: transactions.asMap().entries.map((entry) {
          final tx = entry.value;
          final accent = tx.isIncome
              ? const Color(0xFF16A34A)
              : tx.isTransfer
                  ? AppColors.primary
                  : const Color(0xFFDC2626);
          final icon = tx.isIncome
              ? Icons.south_west_rounded
              : tx.isTransfer
                  ? Icons.swap_horiz_rounded
                  : Icons.north_east_rounded;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent),
                ),
                title: Text(
                  tx.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  '${tx.walletName} • ${_formatDate(tx.date)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                trailing: Text(
                  '${tx.isIncome ? '+' : '-'} ${CurrencyFormatter.formatCompact(tx.amount)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              if (entry.key < transactions.length - 1)
                const Divider(height: 1, indent: 78, endIndent: 18),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleEmptyCard extends StatelessWidget {
  final String title;
  final String description;

  const _SimpleEmptyCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 28,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _EmptyStateCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.error,
              ),
              const SizedBox(height: 14),
              Text(
                'Dashboard gagal dimuat',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day).difference(
    DateTime(date.year, date.month, date.day),
  );

  if (diff.inDays == 0) return 'Hari ini';
  if (diff.inDays == 1) return 'Kemarin';

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

  return '${date.day} ${months[date.month - 1]}';
}

IconData _iconFromName(String iconName) {
  switch (iconName) {
    case 'flight':
      return Icons.flight_takeoff_rounded;
    case 'laptop':
      return Icons.laptop_mac_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'savings':
      return Icons.savings_rounded;
    default:
      return Icons.flag_rounded;
  }
}

Color _parseHexColor(String input) {
  final normalized = input.replaceAll('#', '');
  final buffer = StringBuffer();
  if (normalized.length == 6) {
    buffer.write('ff');
  }
  buffer.write(normalized);
  return Color(int.parse(buffer.toString(), radix: 16));
}
