import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/localization/app_text.dart';
import 'package:ve_wallet/core/preferences/app_preferences_provider.dart';
import 'package:ve_wallet/core/preferences/app_preferences_state.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          t('security_settings_title'),
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
          _buildHeroCard(t),
          const SizedBox(height: 24),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: t('change_password'),
            subtitle: t('security_subtitle'),
            onTap: _isSubmitting ? null : () => _showChangePasswordSheet(t),
          ),
          _buildToggleTile(
            icon: Icons.password_rounded,
            title: t('app_pin'),
            subtitle: prefs.pinEnabled ? t('change_pin') : t('set_pin'),
            value: prefs.pinEnabled,
            onChanged: _isSubmitting ? null : (value) => _handlePinToggle(value),
          ),
          _buildActionTile(
            icon: Icons.pin_outlined,
            title: prefs.pinEnabled ? t('change_pin') : t('set_pin'),
            subtitle: t('pin_hint'),
            onTap: _isSubmitting
                ? null
                : () => _showPinSheet(
                      t,
                      requireCurrentPin: prefs.pinEnabled,
                    ),
          ),
          _buildActionTile(
            icon: Icons.verified_user_outlined,
            title: t('verify_pin'),
            subtitle: prefs.pinEnabled
                ? t('verify')
                : t('app_pin'),
            onTap: _isSubmitting || !prefs.pinEnabled
                ? null
                : () => _showPinVerificationSheet(t),
          ),
          _buildToggleTile(
            icon: Icons.fingerprint_rounded,
            title: t('biometric'),
            subtitle: prefs.biometricEnabled
                ? t('disable_biometric')
                : t('enable_biometric'),
            value: prefs.biometricEnabled,
            onChanged: _isSubmitting
                ? null
                : (value) => _toggleBiometric(value, t),
          ),
          if (_isSubmitting) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroCard(AppText t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_rounded, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            t('security_card_title'),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('security_card_body'),
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFCBD5E1),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        activeThumbColor: AppColors.primary,
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _showChangePasswordSheet(AppText t) async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('change_password'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetField(
                  controller: oldController,
                  label: t('old_password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _sheetField(
                  controller: newController,
                  label: t('new_password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _sheetField(
                  controller: confirmController,
                  label: t('confirm_password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (newController.text.length < 8) {
                        AppUI.showWarning(
                          context,
                          t('new_password_min_length'),
                        );
                        return;
                      }
                      if (newController.text != confirmController.text) {
                        AppUI.showWarning(
                          context,
                          t('password_confirmation_mismatch'),
                        );
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    child: Text(t('save')),
                  ),
                ),
              ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: oldController.text,
            newPassword: newController.text,
          );
      if (!mounted) return;
      AppUI.showSuccess(context, t('success_password_changed'));
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(
        context,
        t.format('password_change_failed', {'error': e}),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handlePinToggle(bool enabled) async {
    final prefs = ref.read(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);

    if (enabled) {
      await _showPinSheet(t, requireCurrentPin: false);
      return;
    }

    final pin = await _showPinPrompt(
      title: t('verify_pin'),
      hint: t('pin_hint'),
    );
    if (pin == null) return;

    setState(() => _isSubmitting = true);
    try {
      final valid = await ref.read(appPreferencesProvider.notifier).verifyPin(pin);
      if (!valid) {
        throw Exception(t('pin_invalid'));
      }
      await ref.read(appPreferencesProvider.notifier).disablePin();
      if (!mounted) return;
      AppUI.showSuccess(context, t('success_pin_disabled'));
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(context, t.format('pin_change_failed', {'error': e}));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showPinSheet(
    AppText t, {
    required bool requireCurrentPin,
  }) async {
    final currentController = TextEditingController();
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                requireCurrentPin ? t('change_pin') : t('set_pin'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (requireCurrentPin) ...[
                _sheetField(
                  controller: currentController,
                  label: t('verify_pin'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
              ],
              _sheetField(
                controller: pinController,
                label: t('pin_hint'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              _sheetField(
                controller: confirmController,
                label: t('confirm_password'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(t('save')),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    final nextPin = pinController.text.trim();
    if (!mounted) return;
    if (!RegExp(r'^\d{4,6}$').hasMatch(nextPin)) {
      AppUI.showWarning(context, t('pin_length_error'));
      return;
    }
    if (nextPin != confirmController.text.trim()) {
      AppUI.showWarning(context, t('pin_confirmation_mismatch'));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (requireCurrentPin) {
        final valid = await ref
            .read(appPreferencesProvider.notifier)
            .verifyPin(currentController.text.trim());
        if (!valid) {
          throw Exception(t('pin_old_mismatch'));
        }
      }
      await ref.read(appPreferencesProvider.notifier).savePin(nextPin);
      if (!mounted) return;
      AppUI.showSuccess(context, t('success_pin_saved'));
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(context, t.format('pin_save_failed', {'error': e}));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showPinVerificationSheet(AppText t) async {
    final pin = await _showPinPrompt(
      title: t('verify_pin'),
      hint: t('pin_hint'),
    );
    if (pin == null) return;

    setState(() => _isSubmitting = true);
    try {
      final valid = await ref.read(appPreferencesProvider.notifier).verifyPin(pin);
      if (!mounted) return;
      if (valid) {
        AppUI.showSuccess(context, t('pin_verified'));
      } else {
        AppUI.showError(context, t('pin_invalid'));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<String?> _showPinPrompt({
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _sheetField(
                controller: controller,
                label: hint,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleBiometric(bool enabled, AppText t) async {
    setState(() => _isSubmitting = true);
    try {
      if (enabled) {
        final auth = ref.read(localAuthenticationProvider);
        final isSupported = await auth.isDeviceSupported();
        final canCheck = await auth.canCheckBiometrics;
        if (!isSupported || !canCheck) {
          throw Exception('Perangkat ini tidak mendukung biometrik');
        }

        final verified = await auth.authenticate(
          localizedReason: 'Verifikasi biometrik untuk mengaktifkan akses cepat',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: false,
          ),
        );

        if (!verified) {
          throw Exception('Verifikasi biometrik dibatalkan');
        }
      }

      await ref.read(appPreferencesProvider.notifier).setBiometricEnabled(
            enabled,
          );
      if (!mounted) return;
      AppUI.showSuccess(context, t('success_biometric_updated'));
    } on PlatformException catch (e) {
      if (!mounted) return;
      AppUI.showError(context, 'Gagal mengakses biometrik: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(
        context,
        t.format('biometric_change_failed', {'error': e}),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
