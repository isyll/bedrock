import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/app_update/domain/app_version_status.dart';
import 'package:bedrock/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late ScriptedVersionApi api;
  late InMemoryKeyValueStorage storage;
  late FakeStoreService store;
  late DateTime now;

  setUp(() {
    api = .new(
      const .success(.new(minimumBuild: 0, latestBuild: 0)),
    );
    storage = .new();
    store = .new();
    now = .utc(2026, 7, 12);
  });

  AppUpdateCubit buildCubit() => .new(
    api: api,
    deviceInfo: testDeviceInfo,
    storage: storage,
    store: store,
    clock: () => now,
  );

  Result<AppVersionStatus> status({
    required int minimum,
    required int latest,
  }) => .success(.new(minimumBuild: minimum, latestBuild: latest));

  group('check', () {
    blocTest<AppUpdateCubit, AppUpdateState>(
      'requires an update when the build is below the minimum',
      build: buildCubit,
      setUp: () => api.result = status(minimum: 50, latest: 60),
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[
        .new(requirement: .required, latestBuild: 60),
      ],
    );

    blocTest<AppUpdateCubit, AppUpdateState>(
      'offers an update with a pending prompt when a newer build exists',
      build: buildCubit,
      setUp: () => api.result = status(minimum: 10, latest: 50),
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[
        .new(
          requirement: .available,
          latestBuild: 50,
          promptPending: true,
        ),
      ],
    );

    blocTest<AppUpdateCubit, AppUpdateState>(
      'does not prompt again for a dismissed build',
      build: buildCubit,
      setUp: () {
        api.result = status(minimum: 10, latest: 50);
        storage.values[StorageKeys.dismissedUpdateBuild] = 50;
      },
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[
        .new(requirement: .available, latestBuild: 50),
      ],
    );

    blocTest<AppUpdateCubit, AppUpdateState>(
      'stays quiet when the app is up to date',
      build: buildCubit,
      setUp: () => api.result = status(minimum: 10, latest: 42),
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[
        .new(latestBuild: 42),
      ],
    );

    blocTest<AppUpdateCubit, AppUpdateState>(
      'keeps state unchanged when the version check fails',
      build: buildCubit,
      setUp: () => api.result = const .failure(
        NetworkException('offline', kind: .offline),
      ),
      act: (cubit) => cubit.check(),
      expect: () => const <AppUpdateState>[],
    );

    test('throttles repeated checks within the interval', () async {
      api.result = status(minimum: 10, latest: 42);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.check();
      await cubit.check();
      expect(api.fetchCalls, 1);

      now = now.add(const .new(hours: 7));
      await cubit.check();
      expect(api.fetchCalls, 2);
    });

    test('skips checks once an update is required', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.notifyUpdateRequired();
      await cubit.check();

      expect(api.fetchCalls, 0);
    });
  });

  blocTest<AppUpdateCubit, AppUpdateState>(
    'notifyUpdateRequired forces the required state once',
    build: buildCubit,
    act: (cubit) => cubit
      ..notifyUpdateRequired()
      ..notifyUpdateRequired(),
    expect: () => const <AppUpdateState>[
      .new(requirement: .required),
    ],
  );

  test('dismissPrompt persists the dismissed build', () async {
    api.result = status(minimum: 10, latest: 50);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.check();
    await cubit.dismissPrompt();

    expect(storage.getInt(StorageKeys.dismissedUpdateBuild), 50);
    expect(cubit.state.promptPending, isFalse);
  });

  test('openStore opens the store listing', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.openStore();

    expect(store.openListingCalls, 1);
  });
}
