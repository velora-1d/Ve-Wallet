import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/localization/app_text.dart';
import 'package:ve_wallet/core/preferences/app_preferences_provider.dart';
import 'package:ve_wallet/core/preferences/app_preferences_state.dart';
import 'package:ve_wallet/core/services/biometric_service.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final prefs =
        ref.watch(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);

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
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Akun'),
            Tab(text: 'Preferensi'),
            Tab(text: 'Tentang'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AccountTab(user: user, t: t),
          _PreferencesTab(prefs: prefs, t: t),
          _AboutTab(t: t),
        ],
      ),
    );
  }
}

class _AccountTab extends ConsumerStatefulWidget {
  final dynamic user;
  final AppText t;

  const _AccountTab({required this.user, required this.t});

  @override
  ConsumerState<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends ConsumerState<_AccountTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SettingsItem> _getSettingsItems() {
    return [
      _SettingsItem(
        icon: Icons.person_outline_rounded,
        iconBgColor: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF3B82F6),
        title: widget.t('personal_info'),
        subtitle: widget.t('personal_info_subtitle'),
        onTap: () => context.push('/profile-info'),
      ),
      _SettingsItem(
        icon: Icons.shield_outlined,
        iconBgColor: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF22C55E),
        title: widget.t('security'),
        subtitle: widget.t('security_subtitle'),
        onTap: () => context.push('/security-settings'),
      ),
      _SettingsItem(
        icon: Icons.notifications_none_rounded,
        iconBgColor: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFF97316),
        title: widget.t('notifications'),
        subtitle: widget.t('notifications_subtitle'),
        onTap: () => context.push('/notifications'),
      ),
      _SettingsItem(
        icon: Icons.people_outline_rounded,
        iconBgColor: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF8B5CF6),
        title: widget.t('shared_account'),
        subtitle: widget.t('shared_account_subtitle'),
        onTap: () => context.push('/shared-account'),
      ),
    ];
  }

  List<_SettingsItem> _getFilteredItems() {
    final items = _getSettingsItems();
    if (_searchQuery.isEmpty) return items;

    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();
    final isSearching = _searchQuery.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        _buildProfileHeader(context, widget.user),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 32),
        if (isSearching && filteredItems.isEmpty)
          _buildNoResults()
        else
          _buildSettingsGroup(
            context,
            title: isSearching
                ? 'Hasil Pencarian (${filteredItems.length})'
                : widget.t('account_security_group'),
            items: [
              ...filteredItems.map(
                (item) => _buildSettingsTile(
                  context,
                  icon: item.icon,
                  iconBgColor: item.iconBgColor,
                  iconColor: item.iconColor,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: item.onTap,
                ),
              ),
              if (!isSearching) _buildBiometricTile(context),
            ],
          ),
        if (widget.user?.role == 'admin') ...[
          const SizedBox(height: 28),
          _buildSettingsGroup(
            context,
            title: widget.t('developer_group'),
            items: [
              SwitchListTile(
                title: Text(
                  widget.t('admin_mode'),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  widget.t('enable_admin_features'),
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
                  widget.t('logout'),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari pengaturan...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD9E3FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
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
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
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

  Widget _buildBiometricTile(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider).asData?.value;
    final isEnabled = prefs?.biometricEnabled ?? false;

    return SwitchListTile(
      title: Text(
        'Autentikasi Biometrik',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        'Gunakan sidik jari atau Face ID untuk login',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: isEnabled,
      onChanged: (value) async {
        if (value) {
          // Authenticate before enabling
          final authenticated = await BiometricService.authenticate(
            localizedReason:
                'Verifikasi untuk mengaktifkan autentikasi biometrik',
          );
          if (authenticated) {
            await ref
                .read(appPreferencesProvider.notifier)
                .setBiometricEnabled(true);
          }
        } else {
          await ref
              .read(appPreferencesProvider.notifier)
              .setBiometricEnabled(false);
        }
      },
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.fingerprint_rounded,
          color: Color(0xFF0EA5E9),
          size: 22,
        ),
      ),
      activeThumbColor: AppColors.primary,
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
            child: Column(children: items),
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

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil pencarian',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for searchable settings items
class _SettingsItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _PreferencesTab extends ConsumerWidget {
  final AppPreferencesState prefs;
  final AppText t;

  const _PreferencesTab({required this.prefs, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageSubtitle = prefs.languageCode == 'en'
        ? t('language_subtitle_en')
        : t('language_subtitle_id');
    final themeSubtitle = switch (prefs.themeKey) {
      'light' => t('theme_subtitle_light'),
      'dark' => t('theme_subtitle_dark'),
      _ => t('theme_subtitle_system'),
    };

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
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
        const SizedBox(height: 40),
      ],
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
            child: Column(children: items),
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

class _AboutTab extends StatelessWidget {
  final AppText t;

  const _AboutTab({required this.t});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A3C95), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  'assets/logos/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ve-Wallet Premium',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versi 1.0.0 (Build 2026.03)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  'Dibuat oleh Mahin Utsman Nawawi, S.H',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildAboutLink(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan Privasi',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildAboutLink(
                context,
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildAboutLink(
                context,
                icon: Icons.star_outline_rounded,
                title: 'Rate Aplikasi',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAboutLink(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
