import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 32),
          _buildSettingsGroup(
            context,
            title: 'Akun & Keamanan',
            items: [
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: 'Informasi Pribadi',
                subtitle: 'Nama, email, dan biodata',
                onTap: () => context.push('/profile-info'),
              ),
              _buildSettingsTile(
                icon: Icons.shield_outlined,
                iconBgColor: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF22C55E),
                title: 'Keamanan',
                subtitle: 'Sandi, PIN, dan biometrik',
                onTap: () => context.push('/security-settings'),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none_rounded,
                iconBgColor: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFF97316),
                title: 'Notifikasi',
                subtitle: 'Atur pemberitahuan Anda',
                onTap: () => context.push('/notifications'),
              ),
              _buildSettingsTile(
                icon: Icons.people_outline_rounded,
                iconBgColor: const Color(0xFFF5F3FF),
                iconColor: const Color(0xFF8B5CF6),
                title: 'Shared Account',
                subtitle: 'Kelola akun bersama',
                onTap: () => context.push('/shared-account'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSettingsGroup(
            context,
            title: 'Preferensi Aplikasi',
            items: [
              _buildSettingsTile(
                icon: Icons.category_outlined,
                iconBgColor: const Color(0xFFFEF2F2),
                iconColor: const Color(0xFFEF4444),
                title: 'Kategori Transaksi',
                subtitle: 'Atur kategori pemasukan & pengeluaran',
                onTap: () => context.push('/category-settings'),
              ),
              _buildSettingsTile(
                icon: Icons.language_rounded,
                iconBgColor: const Color(0xFFECFEFF),
                iconColor: const Color(0xFF06B6D4),
                title: 'Bahasa',
                subtitle: 'Indonesia',
                onTap: () => context.push('/language-settings'),
              ),
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                iconBgColor: const Color(0xFFFDF2F8),
                iconColor: const Color(0xFFEC4899),
                title: 'Tema Visual',
                subtitle: 'Terang / Gelap',
                onTap: () => context.push('/theme-settings'),
              ),
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                iconBgColor: const Color(0xFFF8FAFC),
                iconColor: const Color(0xFF64748B),
                title: 'Pusat Bantuan',
                subtitle: 'Tanya jawab dan dukungan',
                onTap: () => context.push('/help-center'),
              ),
              _buildSettingsTile(
                icon: Icons.auto_awesome_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: 'Tips Harian',
                subtitle: 'Insight singkat biar keputusan keuangan lebih rapi',
                onTap: () => context.push('/tips'),
              ),
            ],
          ),
          if (user?.role == 'admin') ...[
            const SizedBox(height: 28),
            _buildSettingsGroup(
              context,
              title: 'Pengembang',
              items: [
                SwitchListTile(
                  title: Text(
                    'Mode Admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Aktifkan akses fitur admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  value: ref.watch(adminModeProvider),
                  onChanged: (value) {
                    ref.read(adminModeProvider.notifier).state = value;
                    if (value) {
                      context.go('/admin');
                    } else {
                      context.go('/dashboard');
                    }
                  },
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ],
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  'Ve-Wallet Premium',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi 1.0.0 (Build 2026.03)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    'Dibuat oleh Mahin Utsman Nawawi, S.H',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFF8FAFC),
                child: Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.fullName ?? 'Mahin Utsman',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'mahin@velora.id',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Akun Terverifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFCBD5E1),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
