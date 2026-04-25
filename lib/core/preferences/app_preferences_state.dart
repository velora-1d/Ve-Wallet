import 'package:flutter/material.dart';

class AppPreferencesState {
  const AppPreferencesState({
    this.languageCode = 'id',
    this.themeKey = 'system',
    this.pinEnabled = false,
    this.pinHash,
    this.biometricEnabled = false,
  });

  final String languageCode;
  final String themeKey;
  final bool pinEnabled;
  final String? pinHash;
  final bool biometricEnabled;

  Locale get locale => Locale(languageCode);

  ThemeMode get themeMode {
    switch (themeKey) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  AppPreferencesState copyWith({
    String? languageCode,
    String? themeKey,
    bool? pinEnabled,
    String? pinHash,
    bool clearPinHash = false,
    bool? biometricEnabled,
  }) {
    return AppPreferencesState(
      languageCode: languageCode ?? this.languageCode,
      themeKey: themeKey ?? this.themeKey,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinHash: clearPinHash ? null : (pinHash ?? this.pinHash),
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  static const defaults = AppPreferencesState();
}
