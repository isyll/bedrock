import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/services/location/app_location.dart';
import 'package:bedrock/services/permissions/permissions_service.dart';
import 'package:geolocator/geolocator.dart';

final class LocationService {
  const LocationService({
    required this._permissions,
    this._logger = const AppLogger('Location'),
  });

  static const _defaultTimeout = Duration(seconds: 15);

  final PermissionsService _permissions;
  final AppLogger _logger;

  Future<Result<AppLocation>> currentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = _defaultTimeout,
  }) {
    return _guarded(() async {
      await _ensureReady();
      final position = await Geolocator.getCurrentPosition(
        locationSettings: .new(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );
      return AppLocation.fromPosition(position);
    });
  }

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<Result<AppLocation?>> lastKnownLocation() {
    return _guarded(() async {
      await _ensureReady();
      final position = await Geolocator.getLastKnownPosition();
      return position == null ? null : AppLocation.fromPosition(position);
    });
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Stream<AppLocation> watchLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 25,
  }) => Geolocator.getPositionStream(
    locationSettings: .new(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    ),
  ).map(AppLocation.fromPosition);

  Future<void> _ensureReady() async {
    if (!await isServiceEnabled()) {
      throw const LocationException(
        'Location services are disabled',
        serviceDisabled: true,
      );
    }

    final result = await _permissions.ensure(.locationWhenInUse);
    if (result.isUsable) return;

    _logger.info('Location permission refused: ${result.name}');
    throw PermissionException(
      'Missing location permission',
      permanentlyDenied: result == .permanentlyDenied,
    );
  }

  Future<Result<T>> _guarded<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on AppException catch (error) {
      return Result.failure(error);
    } on Exception catch (error, stackTrace) {
      _logger.warning('Location lookup failed', error);
      return Result.failure(
        UnexpectedException(
          'Location lookup failed',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
