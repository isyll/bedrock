import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

final class AppLocation extends Equatable {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyMeters,
    this.altitudeMeters,
    this.speedMetersPerSecond,
    this.headingDegrees,
  });

  factory AppLocation.fromPosition(Position position) {
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracyMeters: position.accuracy,
      altitudeMeters: position.altitude,
      speedMetersPerSecond: position.speed,
      headingDegrees: position.heading,
    );
  }

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracyMeters;
  final double? altitudeMeters;
  final double? speedMetersPerSecond;
  final double? headingDegrees;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    timestamp,
    accuracyMeters,
    altitudeMeters,
    speedMetersPerSecond,
    headingDegrees,
  ];
}
