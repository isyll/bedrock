import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required KeyValueStorage storage})
    : _storage = storage,
      super(_restore(storage));

  final KeyValueStorage _storage;

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }

  static ThemeMode _restore(KeyValueStorage storage) {
    final saved = storage.getString(StorageKeys.themeMode);
    return ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }
}
