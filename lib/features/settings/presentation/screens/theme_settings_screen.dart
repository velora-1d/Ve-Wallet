import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/localization/app_text.dart';
import 'package:ve_wallet/core/preferences/app_preferences_provider.dart';
import 'package:ve_wallet/core/preferences/app_preferences_state.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          t('theme'),
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _ThemeOptionTile(
            title: t('light_mode'),
            value: 'light',
            selected: prefs.themeKey == 'light',
            onTap: _isSaving ? null : () => _saveTheme('light', t),
          ),
          _ThemeOptionTile(
            title: t('dark_mode'),
            value: 'dark',
            selected: prefs.themeKey == 'dark',
            onTap: _isSaving ? null : () => _saveTheme('dark', t),
          ),
          _ThemeOptionTile(
            title: t('system_mode'),
            value: 'system',
            selected: prefs.themeKey == 'system',
            onTap: _isSaving ? null : () => _saveTheme('system', t),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTheme(String themeKey, AppText t) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(appPreferencesProvider.notifier).setTheme(themeKey);
      if (!mounted) return;
      AppUI.showSuccess(context, '${t('theme')} ${t('save').toLowerCase()}');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(
        context,
        t.format('save_theme_failed', {'error': e}),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          value.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
