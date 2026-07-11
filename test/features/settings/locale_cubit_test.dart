import 'dart:ui';

import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryKeyValueStorage storage;

  setUp(() => storage = .new());

  test('defaults to the system locale when nothing is stored', () {
    final cubit = LocaleCubit(storage: storage);
    addTearDown(cubit.close);

    expect(cubit.state, isNull);
    expect(cubit.languageCode, isNull);
  });

  test('restores the persisted locale', () {
    storage.values[StorageKeys.locale] = 'fr';

    final cubit = LocaleCubit(storage: storage);
    addTearDown(cubit.close);

    expect(cubit.state, const Locale('fr'));
    expect(cubit.languageCode, 'fr');
  });

  test('setLocale emits and persists the new locale', () async {
    final cubit = LocaleCubit(storage: storage);
    addTearDown(cubit.close);

    await cubit.setLocale(const .new('en'));

    expect(cubit.state, const Locale('en'));
    expect(storage.getString(StorageKeys.locale), 'en');
  });

  test('setLocale with null returns to the system locale', () async {
    storage.values[StorageKeys.locale] = 'fr';
    final cubit = LocaleCubit(storage: storage);
    addTearDown(cubit.close);

    await cubit.setLocale(null);

    expect(cubit.state, isNull);
    expect(storage.containsKey(StorageKeys.locale), isFalse);
  });
}
