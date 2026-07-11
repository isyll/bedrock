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
  }) : _auth = auth ?? .new();

  final LocalAuthentication _auth;
  final AppLogger _logger;

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate ? .success : .failed;
    } on LocalAuthException catch (error) {
      _logger.info('Biometric authentication error: ${error.code.name}');
      return _mapCode(error.code);
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

  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on Exception catch (error) {
      _logger.warning('Failed to query biometric support', error);
      return false;
    }
  }

  BiometricAuthResult _mapCode(LocalAuthExceptionCode code) => switch (code) {
    .noCredentialsSet || .noBiometricsEnrolled => .notEnrolled,
    .noBiometricHardware ||
    .biometricHardwareTemporarilyUnavailable ||
    .uiUnavailable => .unavailable,
    .temporaryLockout => .lockedOut,
    .biometricLockout => .permanentlyLockedOut,
    _ => .failed,
  };
}
