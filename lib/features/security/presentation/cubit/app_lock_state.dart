part of 'app_lock_cubit.dart';

final class AppLockState extends Equatable {
  const AppLockState({required this.status, this.biometricsSupported = false});

  final AppLockStatus status;
  final bool biometricsSupported;

  bool get isEnabled => status != .disabled;

  bool get isLocked => status == .locked;

  @override
  List<Object?> get props => [status, biometricsSupported];

  AppLockState copyWith({AppLockStatus? status, bool? biometricsSupported}) =>
      .new(
        status: status ?? this.status,
        biometricsSupported: biometricsSupported ?? this.biometricsSupported,
      );
}

enum AppLockStatus { disabled, locked, unlocked }
