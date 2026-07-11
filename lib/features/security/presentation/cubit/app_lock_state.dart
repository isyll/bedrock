part of 'app_lock_cubit.dart';

enum AppLockStatus { disabled, locked, unlocked }

final class AppLockState extends Equatable {
  const AppLockState({required this.status, this.biometricsSupported = false});

  final AppLockStatus status;
  final bool biometricsSupported;

  bool get isEnabled => status != AppLockStatus.disabled;

  bool get isLocked => status == AppLockStatus.locked;

  AppLockState copyWith({AppLockStatus? status, bool? biometricsSupported}) {
    return AppLockState(
      status: status ?? this.status,
      biometricsSupported: biometricsSupported ?? this.biometricsSupported,
    );
  }

  @override
  List<Object?> get props => [status, biometricsSupported];
}
