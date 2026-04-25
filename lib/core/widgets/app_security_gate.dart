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

class AppSecurityGate extends ConsumerStatefulWidget {
  const AppSecurityGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppSecurityGate> createState() => _AppSecurityGateState();
}

class _AppSecurityGateState extends ConsumerState<AppSecurityGate> {
  final _pinController = TextEditingController();
  String? _unlockedUserId;
  String? _lastUserId;
  bool _didAttemptBiometric = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final prefs = ref.watch(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);

    if (user == null) {
      _lastUserId = null;
      _unlockedUserId = null;
      _didAttemptBiometric = false;
      return widget.child;
    }

    if (_lastUserId != user.id) {
      _lastUserId = user.id;
      _unlockedUserId = null;
      _didAttemptBiometric = false;
    }

    final needsLock = prefs.pinEnabled || prefs.biometricEnabled;
    final isUnlocked = !needsLock || _unlockedUserId == user.id;

    if (isUnlocked) {
      return widget.child;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didAttemptBiometric && prefs.biometricEnabled && !_isSubmitting) {
        _authenticateWithBiometric(t: t, autoTriggered: true);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t('security'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prefs.biometricEnabled
                        ? t('unlock_with_biometric_or_pin')
                        : t('unlock_with_pin'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (prefs.pinEnabled) ...[
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: t('pin_hint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : _verifyPinAndUnlock,
                        child: Text(t('verify')),
                      ),
                    ),
                  ],
                  if (prefs.biometricEnabled) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _authenticateWithBiometric(
                                t: t,
                                autoTriggered: false,
                              ),
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: Text(t('biometric')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPinAndUnlock() async {
    final prefs = ref.read(appPreferencesProvider).asData?.value ??
        AppPreferencesState.defaults;
    final t = AppText(prefs.languageCode);
    setState(() => _isSubmitting = true);
    try {
      final isValid = await ref
          .read(appPreferencesProvider.notifier)
          .verifyPin(_pinController.text.trim());
      if (!mounted) return;
      if (!isValid) {
        AppUI.showError(context, t('pin_invalid'));
        return;
      }
      setState(() {
        _unlockedUserId = ref.read(currentUserProvider)?.id;
        _pinController.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _authenticateWithBiometric({
    required AppText t,
    required bool autoTriggered,
  }) async {
    _didAttemptBiometric = true;
    setState(() => _isSubmitting = true);
    try {
      final auth = ref.read(localAuthenticationProvider);
      final isSupported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      if (!isSupported || !canCheck) {
        if (!autoTriggered && mounted) {
          AppUI.showWarning(context, t('biometric_not_available'));
        }
        return;
      }

      final verified = await auth.authenticate(
        localizedReason: 'Verifikasi biometrik untuk membuka aplikasi',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
        ),
      );

      if (!mounted) return;
      if (verified) {
        setState(() {
          _unlockedUserId = ref.read(currentUserProvider)?.id;
        });
      } else if (!autoTriggered) {
        AppUI.showWarning(context, t('biometric_cancelled'));
      }
    } on PlatformException catch (e) {
      if (!mounted || autoTriggered) return;
      AppUI.showError(context, 'Gagal mengakses biometrik: ${e.message}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
