import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/localization/app_text.dart';
import 'package:ve_wallet/core/preferences/app_preferences_provider.dart';
import 'package:ve_wallet/core/preferences/app_preferences_state.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
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
          t('language'),
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
          _LanguageOptionTile(
            title: t('indonesian'),
            subtitle: 'ID',
            selected: prefs.languageCode == 'id',
            onTap: _isSaving ? null : () => _saveLanguage('id', t),
          ),
          _LanguageOptionTile(
            title: t('english'),
            subtitle: 'EN',
            selected: prefs.languageCode == 'en',
            onTap: _isSaving ? null : () => _saveLanguage('en', t),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLanguage(String code, AppText t) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(appPreferencesProvider.notifier).setLanguage(code);
      if (!mounted) return;
      AppUI.showSuccess(context, '${t('language')} ${t('save').toLowerCase()}');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(
        context,
        t.format('save_language_failed', {'error': e}),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
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
