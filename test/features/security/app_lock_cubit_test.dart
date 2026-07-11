import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/security/presentation/cubit/app_lock_cubit.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late FakeBiometricsService biometrics;

  setUp(() {
    storage = InMemoryKeyValueStorage();
    biometrics = FakeBiometricsService();
  });

  AppLockCubit buildCubit() =>
      AppLockCubit(storage: storage, biometrics: biometrics);

  test('starts disabled and discovers biometric support', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, AppLockStatus.disabled);

    await pumpEventQueue();
    expect(cubit.state.biometricsSupported, isTrue);
  });

  test('starts locked when the lock was previously enabled', () async {
    storage.values[StorageKeys.biometricLock] = true;

    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.isLocked, isTrue);
  });

  test('auto unlocks when biometrics become unsupported', () async {
    storage.values[StorageKeys.biometricLock] = true;
    biometrics.supported = false;

    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    expect(cubit.state.isLocked, isFalse);
    expect(cubit.state.status, AppLockStatus.unlocked);
  });

  test('enable authenticates then persists the lock', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    final result = await cubit.enable('reason');

    expect(result, BiometricAuthResult.success);
    expect(cubit.state.isEnabled, isTrue);
    expect(storage.getBool(StorageKeys.biometricLock), isTrue);
    expect(biometrics.authenticateCalls, 1);
  });

  test('enable refuses when biometrics are unsupported', () async {
    biometrics.supported = false;
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    final result = await cubit.enable('reason');

    expect(result, BiometricAuthResult.unavailable);
    expect(cubit.state.isEnabled, isFalse);
    expect(biometrics.authenticateCalls, 0);
  });

  test('enable keeps the lock off when authentication fails', () async {
    biometrics.authResult = BiometricAuthResult.failed;
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    final result = await cubit.enable('reason');

    expect(result, BiometricAuthResult.failed);
    expect(cubit.state.isEnabled, isFalse);
    expect(storage.containsKey(StorageKeys.biometricLock), isFalse);
  });

  test('unlock succeeds only after authentication', () async {
    storage.values[StorageKeys.biometricLock] = true;
    biometrics.authResult = BiometricAuthResult.failed;
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    expect(await cubit.unlock('reason'), BiometricAuthResult.failed);
    expect(cubit.state.isLocked, isTrue);

    biometrics.authResult = BiometricAuthResult.success;
    expect(await cubit.unlock('reason'), BiometricAuthResult.success);
    expect(cubit.state.status, AppLockStatus.unlocked);
  });

  test('lock only takes effect while unlocked', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    cubit.lock();
    expect(cubit.state.status, AppLockStatus.disabled);

    await cubit.enable('reason');
    cubit.lock();
    expect(cubit.state.isLocked, isTrue);
  });

  test('disable authenticates then removes the lock', () async {
    storage.values[StorageKeys.biometricLock] = true;
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await pumpEventQueue();

    final result = await cubit.disable('reason');

    expect(result, BiometricAuthResult.success);
    expect(cubit.state.status, AppLockStatus.disabled);
    expect(storage.containsKey(StorageKeys.biometricLock), isFalse);
  });
}
