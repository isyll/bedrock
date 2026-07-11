import 'dart:async';

import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_lock_state.dart';

final class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({required KeyValueStorage storage, required this._biometrics})
    : _storage = storage,
      super(_restore(storage)) {
    unawaited(_refreshSupport());
  }

  final KeyValueStorage _storage;
  final BiometricsService _biometrics;

  static AppLockState _restore(KeyValueStorage storage) {
    final enabled = storage.getBool(StorageKeys.biometricLock) ?? false;
    return AppLockState(
      status: enabled ? AppLockStatus.locked : AppLockStatus.disabled,
    );
  }

  Future<void> _refreshSupport() async {
    final supported = await _biometrics.isSupported();
    if (isClosed) return;
    emit(state.copyWith(biometricsSupported: supported));
    if (!supported && state.isLocked) {
      emit(state.copyWith(status: AppLockStatus.unlocked));
    }
  }

  Future<BiometricAuthResult> enable(String reason) async {
    if (!state.biometricsSupported) return BiometricAuthResult.unavailable;

    final result = await _biometrics.authenticate(reason: reason);
    if (result.isSuccess) {
      await _storage.setBool(StorageKeys.biometricLock, value: true);
      emit(state.copyWith(status: AppLockStatus.unlocked));
    }
    return result;
  }

  Future<BiometricAuthResult> disable(String reason) async {
    if (!state.isEnabled) return BiometricAuthResult.success;

    final result = await _biometrics.authenticate(reason: reason);
    if (result.isSuccess) {
      await _storage.remove(StorageKeys.biometricLock);
      emit(state.copyWith(status: AppLockStatus.disabled));
    }
    return result;
  }

  void lock() {
    if (state.status != AppLockStatus.unlocked) return;
    emit(state.copyWith(status: AppLockStatus.locked));
  }

  Future<BiometricAuthResult> unlock(String reason) async {
    if (!state.isLocked) return BiometricAuthResult.success;

    final result = await _biometrics.authenticate(reason: reason);
    if (result.isSuccess) {
      emit(state.copyWith(status: AppLockStatus.unlocked));
    }
    return result;
  }
}
