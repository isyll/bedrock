import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/app_update/data/app_update_service.dart';
import 'package:bedrock/services/store/store_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_update_state.dart';

final class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({
    required this._service,
    required this._storage,
    required this._store,
    this._checkInterval = const .new(hours: 6),
    this._clock = DateTime.now,
  }) : super(const .new());

  final AppUpdateService _service;
  final KeyValueStorage _storage;
  final StoreService _store;
  final Duration _checkInterval;
  final DateTime Function() _clock;

  DateTime? _lastCheckedAt;

  Future<void> check() async {
    final now = _clock();
    final lastCheckedAt = _lastCheckedAt;
    final throttled =
        lastCheckedAt != null && now.difference(lastCheckedAt) < _checkInterval;
    if (throttled) return;
    _lastCheckedAt = now;

    final version = await _service.check();
    if (isClosed || version == null) return;
    if (version == _storage.getString(StorageKeys.dismissedUpdateVersion)) {
      return;
    }

    emit(.new(availableVersion: version));
  }

  void clear() {
    if (isClosed) return;
    emit(const .new());
  }

  Future<void> dismiss() async {
    final version = state.availableVersion;
    if (version != null) {
      await _storage.setString(StorageKeys.dismissedUpdateVersion, version);
    }
    if (isClosed) return;
    emit(const .new());
  }

  Future<void> openStore() => _store.openListing();
}
