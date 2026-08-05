import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if hardware supports biometric authentication.
  Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Returns available biometric hardware types (Fingerprint, Face, Iris).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Triggers biometric authentication prompt with hardware/OS PIN fallback.
  Future<bool> authenticate({
    required String localizedReason,
  }) async {
    try {
      final bool canAuth = await canAuthenticate();
      if (!canAuth) return true; // Fail open for devices without biometrics enabled

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows device PIN/Pattern fallback, never hardcoded PIN
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
