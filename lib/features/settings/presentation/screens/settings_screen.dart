import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/localization/app_text.dart';
import 'package:ve_wallet/core/preferences/app_preferences_provider.dart';
import 'package:ve_wallet/core/preferences/app_preferences_state.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final prefs = ref.watch(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);

    final languageSubtitle = prefs.languageCode == 'en'
        ? t('language_subtitle_en')
        : t('language_subtitle_id');
    final themeSubtitle = switch (prefs.themeKey) {
      'light' => t('theme_subtitle_light'),
      'dark' => t('theme_subtitle_dark'),
      _ => t('theme_subtitle_system'),
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          t('settings'),
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onSurface,
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
            title: t('account_security_group'),
            items: [
              _buildSettingsTile(
                context,
                icon: Icons.person_outline_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: t('personal_info'),
                subtitle: t('personal_info_subtitle'),
                onTap: () => context.push('/profile-info'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.shield_outlined,
                iconBgColor: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF22C55E),
                title: t('security'),
                subtitle: t('security_subtitle'),
                onTap: () => context.push('/security-settings'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none_rounded,
                iconBgColor: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFF97316),
                title: t('notifications'),
                subtitle: t('notifications_subtitle'),
                onTap: () => context.push('/notifications'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.people_outline_rounded,
                iconBgColor: const Color(0xFFF5F3FF),
                iconColor: const Color(0xFF8B5CF6),
                title: t('shared_account'),
                subtitle: t('shared_account_subtitle'),
                onTap: () => context.push('/shared-account'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSettingsGroup(
            context,
            title: t('app_preferences_group'),
            items: [
              _buildSettingsTile(
                context,
                icon: Icons.category_outlined,
                iconBgColor: const Color(0xFFFEF2F2),
                iconColor: const Color(0xFFEF4444),
                title: t('transaction_categories'),
                subtitle: t('categories_subtitle'),
                onTap: () => context.push('/category-settings'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.language_rounded,
                iconBgColor: const Color(0xFFECFEFF),
                iconColor: const Color(0xFF06B6D4),
                title: t('language'),
                subtitle: languageSubtitle,
                onTap: () => context.push('/language-settings'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.palette_outlined,
                iconBgColor: const Color(0xFFFDF2F8),
                iconColor: const Color(0xFFEC4899),
                title: t('theme'),
                subtitle: themeSubtitle,
                onTap: () => context.push('/theme-settings'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.help_outline_rounded,
                iconBgColor: const Color(0xFFF8FAFC),
                iconColor: const Color(0xFF64748B),
                title: t('help_center'),
                subtitle: t('help_center_subtitle'),
                onTap: () => context.push('/help-center'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.auto_awesome_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: t('daily_tips'),
                subtitle: t('tips_subtitle'),
                onTap: () => context.push('/tips'),
              ),
            ],
          ),
          if (user?.role == 'admin') ...[
            const SizedBox(height: 28),
            _buildSettingsGroup(
              context,
              title: t('developer_group'),
              items: [
                SwitchListTile(
                  title: Text(
                    t('admin_mode'),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    t('enable_admin_features'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    t('logout'),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi 1.0.0 (Build 2026.03)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    'Dibuat oleh Mahin Utsman Nawawi, S.H',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'mahin@velora.id',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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

  Widget _buildSettingsTile(
    BuildContext context, {
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
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.outline,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
