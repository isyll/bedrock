import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/services/store/store_service.dart';

class AppReviewService {
  AppReviewService({
    required this._storage,
    required this._store,
    this._minSessions = 5,
    this._minUsage = const .new(days: 3),
    this._minInterval = const .new(days: 90),
    this._clock = DateTime.now,
  });

  final KeyValueStorage _storage;
  final StoreService _store;
  final int _minSessions;
  final Duration _minUsage;
  final Duration _minInterval;
  final DateTime Function() _clock;

  Future<void> maybeRequestReview() async {
    if (!_shouldPrompt()) return;

    final prompted = await _store.requestReview();
    if (prompted) {
      await _storage.setString(
        StorageKeys.reviewLastPromptAt,
        _clock().toIso8601String(),
      );
    }
  }

  Future<void> recordSession() async {
    final count = (_storage.getInt(StorageKeys.reviewSessionCount) ?? 0) + 1;
    await _storage.setInt(StorageKeys.reviewSessionCount, count);

    if (_readDate(StorageKeys.reviewFirstSessionAt) == null) {
      await _storage.setString(
        StorageKeys.reviewFirstSessionAt,
        _clock().toIso8601String(),
      );
    }
  }

  DateTime? _readDate(String key) {
    final raw = _storage.getString(key);
    return raw == null ? null : .tryParse(raw);
  }

  bool _shouldPrompt() {
    final sessions = _storage.getInt(StorageKeys.reviewSessionCount) ?? 0;
    if (sessions < _minSessions) return false;

    final firstSessionAt = _readDate(StorageKeys.reviewFirstSessionAt);
    if (firstSessionAt == null) return false;
    if (_clock().difference(firstSessionAt) < _minUsage) return false;

    final lastPromptAt = _readDate(StorageKeys.reviewLastPromptAt);
    if (lastPromptAt != null &&
        _clock().difference(lastPromptAt) < _minInterval) {
      return false;
    }

    return true;
  }
}
