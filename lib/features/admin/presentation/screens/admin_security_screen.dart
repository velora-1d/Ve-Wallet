import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class AdminSecurityScreen extends StatelessWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildSectionTitle('Prioritas Hari Ini'),
        const SizedBox(height: 12),
        _buildAlertTile(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: '3 login gagal beruntun',
          subtitle: 'Pantau akun yang mencoba masuk lebih dari 5 kali.',
        ),
        _buildAlertTile(
          icon: Icons.lock_clock_outlined,
          iconColor: AppColors.primary,
          title: '12 sesi aktif lebih dari 7 hari',
          subtitle: 'Review device lama dan paksa logout jika perlu.',
        ),
        _buildAlertTile(
          icon: Icons.verified_user_outlined,
          iconColor: const Color(0xFF10B981),
          title: 'RLS dan policy aktif',
          subtitle: 'Tidak ada perubahan rule yang belum ditinjau.',
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Checklist Operasional'),
        const SizedBox(height: 12),
        _buildChecklistItem(
          label: 'Audit role admin',
          detail: 'Pastikan hanya akun inti yang punya akses admin.',
        ),
        _buildChecklistItem(
          label: 'Rotasi service key',
          detail: 'Jadwalkan rotasi kredensial internal per 90 hari.',
        ),
        _buildChecklistItem(
          label: 'Verifikasi email confirmation',
          detail: 'Cek user baru yang tertahan karena belum verifikasi.',
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tidak ada insiden kritis. Fokus pada hygiene akun dan sesi aktif.',
            style: TextStyle(color: Color(0xFFD6E4FF), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
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
