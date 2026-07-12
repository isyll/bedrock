import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/app_update/data/app_version_api.dart';
import 'package:bedrock/features/app_update/domain/app_version_status.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:bedrock/services/store/store_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_update_state.dart';

final class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({
    required this._api,
    required this._deviceInfo,
    required this._storage,
    required this._store,
    this._checkInterval = const .new(hours: 6),
    this._clock = DateTime.now,
    this._logger = const .new('AppUpdateCubit'),
  }) : super(const .new());

  final AppVersionApi _api;
  final DeviceInfo _deviceInfo;
  final KeyValueStorage _storage;
  final StoreService _store;
  final Duration _checkInterval;
  final DateTime Function() _clock;
  final AppLogger _logger;

  DateTime? _lastCheckedAt;

  Future<void> check() async {
    if (state.updateRequired) return;

    final now = _clock();
    final lastCheckedAt = _lastCheckedAt;
    final throttled =
        lastCheckedAt != null && now.difference(lastCheckedAt) < _checkInterval;
    if (throttled) return;
    _lastCheckedAt = now;

    final result = await _api.fetchStatus();
    if (isClosed) return;

    result.fold(
      onSuccess: _apply,
      onFailure: (exception) =>
          _logger.debug('Version check failed: ${exception.message}'),
    );
  }

  Future<void> dismissPrompt() async {
    await _storage.setInt(StorageKeys.dismissedUpdateBuild, state.latestBuild);
    if (isClosed) return;
    emit(state.copyWith(promptPending: false));
  }

  void notifyUpdateRequired() {
    if (state.updateRequired) return;
    emit(state.copyWith(requirement: .required, promptPending: false));
  }

  Future<void> openStore() => _store.openListing();

  void _apply(AppVersionStatus status) {
    final requirement = status.requirementFor(_deviceInfo.buildNumberValue);
    final dismissedBuild =
        _storage.getInt(StorageKeys.dismissedUpdateBuild) ?? 0;

    emit(
      .new(
        requirement: requirement,
        latestBuild: status.latestBuild,
        promptPending:
            requirement == .available && status.latestBuild > dismissedBuild,
      ),
    );
  }
}
