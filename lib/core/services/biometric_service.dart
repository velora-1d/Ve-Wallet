import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service for handling biometric authentication
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  static Future<bool> authenticate({
    String localizedReason = 'Silakan verifikasi identitas Anda',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
  }) async {
    try {
      final bool isAvailable = await canCheckBiometrics();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }

  /// Authenticate with device credentials (PIN/Password/Pattern) as fallback
  static Future<bool> authenticateWithDeviceCredentials({
    String localizedReason = 'Silakan verifikasi identitas Anda',
  }) async {
    try {
      final bool isAvailable = await isDeviceSupported();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: false,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Error during device credential authentication: $e');
      return false;
    }
  }

  /// Stop authentication
  static Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } on PlatformException catch (e) {
      debugPrint('Error stopping authentication: $e');
      return false;
    }
  }
}
