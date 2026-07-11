import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  const SecureStorage({this._logger = const .new('SecureStorage')});

  static const _storage = FlutterSecureStorage(
    aOptions: .new(migrateWithBackup: true),
    iOptions: .new(
      accessibility: .first_unlock_this_device,
    ),
  );

  final AppLogger _logger;

  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } on PlatformException {
      return false;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (error) {
      _logger.warning('Failed to delete secure value for $key', error);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException catch (error) {
      _logger.warning('Failed to clear secure storage', error);
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (error) {
      _logger.warning('Failed to read secure value for $key', error);
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Failed to write secure value for $key',
        error,
        stackTrace,
      );
      throw const StorageException('Failed to persist a secure value');
    }
  }
}
