import 'dart:ui';

import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({required KeyValueStorage storage})
    : _storage = storage,
      super(_restore(storage));

  final KeyValueStorage _storage;

  String? get languageCode => state?.languageCode;

  Future<void> setLocale(Locale? locale) async {
    if (locale == state) return;
    emit(locale);
    if (locale == null) {
      await _storage.remove(StorageKeys.locale);
    } else {
      await _storage.setString(StorageKeys.locale, locale.languageCode);
    }
  }

  static Locale? _restore(KeyValueStorage storage) {
    final saved = storage.getString(StorageKeys.locale);
    return saved == null ? null : Locale(saved);
  }
}
