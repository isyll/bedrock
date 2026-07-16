import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late final InMemoryKeyValueStorage storage;

  setUp(() => storage = .new());

  test('defaults to system when nothing is stored', () {
    final cubit = ThemeCubit(storage: storage);
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.system);
  });

  test('restores the persisted mode', () {
    storage.values[StorageKeys.themeMode] = ThemeMode.dark.name;

    final cubit = ThemeCubit(storage: storage);
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.dark);
  });

  test('falls back to system for unknown stored values', () {
    storage.values[StorageKeys.themeMode] = 'sepia';

    final cubit = ThemeCubit(storage: storage);
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.system);
  });

  test('setMode emits and persists the new mode', () async {
    final cubit = ThemeCubit(storage: storage);
    addTearDown(cubit.close);

    await cubit.setMode(.light);

    expect(cubit.state, ThemeMode.light);
    expect(storage.getString(StorageKeys.themeMode), 'light');
  });
}
