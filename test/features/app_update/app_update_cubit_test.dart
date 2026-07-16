import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late final FakeAppUpdateService service;
  late final InMemoryKeyValueStorage storage;
  late final FakeStoreService store;
  late final DateTime now;

  setUp(() {
    service = .new();
    storage = .new();
    store = .new();
    now = .utc(2026, 7, 12);
  });

  AppUpdateCubit buildCubit() => .new(
    service: service,
    storage: storage,
    store: store,
    clock: () => now,
  );

  group('check', () {
    blocTest<AppUpdateCubit, AppUpdateState>(
      'emits the newer store version so the user can be prompted',
      build: buildCubit,
      setUp: () => service.storeVersion = '2.0.0',
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[
        .new(availableVersion: '2.0.0'),
      ],
    );

    blocTest<AppUpdateCubit, AppUpdateState>(
      'stays idle when nothing needs a prompt',
      build: buildCubit,
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[],
    );

    blocTest<AppUpdateCubit, AppUpdateState>(
      'does not prompt again for a dismissed version',
      build: buildCubit,
      setUp: () {
        service.storeVersion = '2.0.0';
        storage.values[StorageKeys.dismissedUpdateVersion] = '2.0.0';
      },
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[],
    );

    test('throttles repeated checks within the interval', () async {
      service.storeVersion = '2.0.0';
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.check();
      await cubit.check();
      expect(service.checkCalls, 1);

      now = now.add(const .new(hours: 7));
      await cubit.check();
      expect(service.checkCalls, 2);
    });
  });

  test('dismiss persists the version and clears the prompt', () async {
    service.storeVersion = '2.0.0';
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.check();
    await cubit.dismiss();

    expect(storage.getString(StorageKeys.dismissedUpdateVersion), '2.0.0');
    expect(cubit.state.updateAvailable, isFalse);
  });

  test('openStore opens the store listing', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.openStore();

    expect(store.openListingCalls, 1);
  });
}
