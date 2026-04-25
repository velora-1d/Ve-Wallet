import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/admin/presentation/providers/admin_dashboard_provider.dart';

class AdminSecurityScreen extends ConsumerWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Security Panel',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: dashboardAsync.when(
        data: (data) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _buildSummaryCard(data.activeToday, data.totalUsers),
            const SizedBox(height: 32),
            _buildSectionTitle('Prioritas Hari Ini'),
            const SizedBox(height: 16),
            _buildAlertTile(
              icon: Icons.group_rounded,
              iconColor: AppColors.primary,
              title: '${data.totalUsers} user terdaftar',
              subtitle: 'Total akun yang saat ini tercatat di sistem.',
            ),
            _buildAlertTile(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFF10B981),
              title: '${data.activeToday} user aktif hari ini',
              subtitle: 'Diukur dari aktivitas masuk terbaru pengguna hari ini.',
            ),
            _buildAlertTile(
              icon: Icons.swap_horiz_rounded,
              iconColor: AppColors.secondary,
              title: '${data.totalTransactions} transaksi tercatat',
              subtitle: 'Jumlah transaksi yang sudah tercatat di aplikasi.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Checklist Operasional'),
            const SizedBox(height: 16),
            _buildChecklistItem(
              label: 'Akses admin',
              detail:
                  'Panel ini hanya bisa dibuka oleh akun yang memiliki akses admin.',
            ),
            _buildChecklistItem(
              label: 'Household aktif',
              detail:
                  '${data.totalHouseholds} household saat ini aktif di aplikasi.',
            ),
            _buildChecklistItem(
              label: 'Aktivitas terbaru',
              detail:
                  '${data.activities.length} log terbaru tersedia di menu History untuk audit cepat.',
            ),
            const SizedBox(height: 40),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal memuat ringkasan security: $error')),
      ),
    );
  }

  Widget _buildSummaryCard(int activeToday, int totalUsers) {
    final healthText = totalUsers == 0
        ? 'Belum ada data user untuk dianalisis.'
        : 'Monitoring aktif. $activeToday dari $totalUsers user terdeteksi aktif hari ini.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Security Status',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.shield_rounded,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            healthText,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Terakhir diperbarui: otomatis',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildAlertTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required String detail,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
