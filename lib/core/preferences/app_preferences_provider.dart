import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ve_wallet/core/preferences/app_preferences_state.dart';
import 'package:ve_wallet/core/providers/secure_storage_provider.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';

final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

class AppPreferencesController extends AsyncNotifier<AppPreferencesState> {
  static const _languageKey = 'app_language';
  static const _themeKey = 'app_theme';
  static const _pinEnabledKey = 'pin_enabled';
  static const _pinHashKey = 'pin_hash';
  static const _biometricEnabledKey = 'biometric_enabled';

  @override
  Future<AppPreferencesState> build() async {
    final currentUser = ref.watch(currentUserProvider);
    final storage = ref.read(secureStorageProvider);
    final localState = AppPreferencesState(
      languageCode: _normalizeLanguage(await storage.read(key: _languageKey)),
      themeKey: _normalizeTheme(await storage.read(key: _themeKey)),
      pinEnabled: (await storage.read(key: _pinEnabledKey)) == 'true',
      pinHash: await storage.read(key: _pinHashKey),
      biometricEnabled:
          (await storage.read(key: _biometricEnabledKey)) == 'true',
    );

    if (currentUser == null) {
      return localState;
    }

    final supabase = ref.read(supabaseProvider);
    try {
      final profile = await supabase
          .from('profiles')
          .select('language, theme, pin_enabled, pin_hash, biometric_enabled')
          .eq('id', currentUser.id)
          .maybeSingle();

      final merged = localState.copyWith(
        languageCode: _normalizeLanguage(profile?['language'] as String?),
        themeKey: _normalizeTheme(profile?['theme'] as String?),
        pinEnabled: profile?['pin_enabled'] as bool? ?? localState.pinEnabled,
        pinHash: profile?['pin_hash'] as String? ?? localState.pinHash,
        biometricEnabled: profile?['biometric_enabled'] as bool? ??
            localState.biometricEnabled,
      );

      await _writeLocal(merged);
      return merged;
    } catch (_) {
      return localState;
    }
  }

  String _normalizeLanguage(String? value) {
    return value == 'en' ? 'en' : 'id';
  }

  String _normalizeTheme(String? value) {
    if (value == 'light' || value == 'dark') return value!;
    return 'system';
  }

  Future<void> _writeLocal(AppPreferencesState prefs) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _languageKey, value: prefs.languageCode);
    await storage.write(key: _themeKey, value: prefs.themeKey);
    await storage.write(key: _pinEnabledKey, value: prefs.pinEnabled.toString());
    await storage.write(
      key: _biometricEnabledKey,
      value: prefs.biometricEnabled.toString(),
    );
    if (prefs.pinHash == null || prefs.pinHash!.isEmpty) {
      await storage.delete(key: _pinHashKey);
    } else {
      await storage.write(key: _pinHashKey, value: prefs.pinHash);
    }
  }

  Future<void> _writeRemote(Map<String, dynamic> values) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final supabase = ref.read(supabaseProvider);
    await supabase.from('profiles').update(values).eq('id', user.id);
  }

  Future<void> setLanguage(String languageCode) async {
    final previous = state.asData?.value ?? AppPreferencesState.defaults;
    final next = previous.copyWith(languageCode: _normalizeLanguage(languageCode));
    state = AsyncData(next);
    await _writeLocal(next);
    await _writeRemote({'language': next.languageCode});
  }

  Future<void> setTheme(String themeKey) async {
    final previous = state.asData?.value ?? AppPreferencesState.defaults;
    final next = previous.copyWith(themeKey: _normalizeTheme(themeKey));
    state = AsyncData(next);
    await _writeLocal(next);
    await _writeRemote({'theme': next.themeKey});
  }

  Future<void> savePin(String pin) async {
    final previous = state.asData?.value ?? AppPreferencesState.defaults;
    final hashed = _hashPin(pin);
    final next = previous.copyWith(
      pinEnabled: true,
      pinHash: hashed,
    );
    state = AsyncData(next);
    await _writeLocal(next);
    await _writeRemote({
      'pin_enabled': true,
      'pin_hash': hashed,
    });
  }

  Future<bool> verifyPin(String pin) async {
    final current = state.asData?.value ?? AppPreferencesState.defaults;
    if ((current.pinHash ?? '').isEmpty) {
      return false;
    }
    return current.pinHash == _hashPin(pin);
  }

  Future<void> disablePin() async {
    final previous = state.asData?.value ?? AppPreferencesState.defaults;
    final next = previous.copyWith(
      pinEnabled: false,
      clearPinHash: true,
    );
    state = AsyncData(next);
    await _writeLocal(next);
    await _writeRemote({
      'pin_enabled': false,
      'pin_hash': null,
    });
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final previous = state.asData?.value ?? AppPreferencesState.defaults;
    final next = previous.copyWith(biometricEnabled: enabled);
    state = AsyncData(next);
    await _writeLocal(next);
    await _writeRemote({'biometric_enabled': enabled});
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }
}

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferencesState>(
      AppPreferencesController.new,
    );
