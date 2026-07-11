import 'package:bedrock/core/logging/app_logger.dart';
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

class BiometricsService {
  BiometricsService({
    LocalAuthentication? auth,
    this._logger = const AppLogger('Biometrics'),
  }) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;
  final AppLogger _logger;

  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on Exception catch (error) {
      _logger.warning('Failed to query biometric support', error);
      return false;
    }
  }

  Future<List<BiometricType>> enrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on Exception catch (error) {
      _logger.warning('Failed to query enrolled biometrics', error);
      return const [];
    }
  }

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate
          ? BiometricAuthResult.success
          : BiometricAuthResult.failed;
    } on LocalAuthException catch (error) {
      _logger.info('Biometric authentication error: ${error.code.name}');
      return _mapCode(error.code);
    }
  }

  BiometricAuthResult _mapCode(LocalAuthExceptionCode code) {
    return switch (code) {
      LocalAuthExceptionCode.noCredentialsSet ||
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        BiometricAuthResult.notEnrolled,
      LocalAuthExceptionCode.noBiometricHardware ||
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
      LocalAuthExceptionCode.uiUnavailable => BiometricAuthResult.unavailable,
      LocalAuthExceptionCode.temporaryLockout => BiometricAuthResult.lockedOut,
      LocalAuthExceptionCode.biometricLockout =>
        BiometricAuthResult.permanentlyLockedOut,
      _ => BiometricAuthResult.failed,
    };
  }
}
