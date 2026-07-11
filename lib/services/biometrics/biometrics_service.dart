import 'package:bedrock/core/logging/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

enum BiometricAuthResult {
  success,
  failed,
  unavailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut;

  bool get isSuccess => this == success;
}

final class BiometricsService {
  BiometricsService({
    LocalAuthentication? auth,
    this._logger = const AppLogger('Biometrics'),
  }) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;
  final AppLogger _logger;

  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (error) {
      _logger.warning('Failed to query biometric support', error);
      return false;
    }
  }

  Future<List<BiometricType>> enrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (error) {
      _logger.warning('Failed to query enrolled biometrics', error);
      return const [];
    }
  }

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      return didAuthenticate
          ? BiometricAuthResult.success
          : BiometricAuthResult.failed;
    } on PlatformException catch (error) {
      _logger.info('Biometric authentication error: ${error.code}');
      return switch (error.code) {
        auth_error.notEnrolled ||
        auth_error.passcodeNotSet => BiometricAuthResult.notEnrolled,
        auth_error.lockedOut => BiometricAuthResult.lockedOut,
        auth_error.permanentlyLockedOut =>
          BiometricAuthResult.permanentlyLockedOut,
        auth_error.notAvailable ||
        auth_error.otherOperatingSystem => BiometricAuthResult.unavailable,
        _ => BiometricAuthResult.failed,
      };
    }
  }
}
