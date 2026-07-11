import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _config = AppConfig(
  flavor: AppFlavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);

void main() {
  late InMemorySecureStorage secureStorage;
  late InMemoryKeyValueStorage keyValueStorage;
  late ScriptedAuthApi api;
  late SessionManager session;
  late AuthRepository repository;

  SignInResult successfulSignIn() => SignInResult(
    user: ScriptedAuthApi.demoUser,
    tokens: AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    ),
  );

  setUp(() {
    secureStorage = InMemorySecureStorage();
    keyValueStorage = InMemoryKeyValueStorage();
    api = ScriptedAuthApi();
    session = SessionManager(config: _config, storage: secureStorage);
    repository = AuthRepository(
      api: api,
      session: session,
      storage: keyValueStorage,
    );
  });

  tearDown(() {
    session.dispose();
  });

  test('restore without stored tokens reports unauthenticated', () async {
    await repository.restore();

    expect(repository.currentStatus, AuthStatus.unauthenticated);
    expect(repository.currentUser, isNull);
  });

  test('signIn stores the session and caches the user', () async {
    api.signInResult = successfulSignIn();

    final result = await repository.signIn(
      email: 'demo@example.com',
      password: 'password1',
    );

    expect(result.isSuccess, isTrue);
    expect(repository.currentStatus, AuthStatus.authenticated);
    expect(repository.currentUser, ScriptedAuthApi.demoUser);
    expect(secureStorage.values[StorageKeys.accessToken], 'access');
    expect(keyValueStorage.getString(StorageKeys.currentUser), isNotNull);
  });

  test('restore recovers the cached user from a previous run', () async {
    api.signInResult = successfulSignIn();
    await repository.signIn(email: 'demo@example.com', password: 'password1');

    final revived = SessionManager(config: _config, storage: secureStorage);
    addTearDown(revived.dispose);
    final restoredRepository = AuthRepository(
      api: api,
      session: revived,
      storage: keyValueStorage,
    );
    await restoredRepository.restore();

    expect(restoredRepository.currentStatus, AuthStatus.authenticated);
    expect(restoredRepository.currentUser, ScriptedAuthApi.demoUser);
  });

  test('signIn maps API failures without touching the session', () async {
    await repository.restore();
    api.signInError = unauthorizedDioException();

    final result = await repository.signIn(
      email: 'demo@example.com',
      password: 'wrong',
    );

    expect(result.exceptionOrNull, isA<UnauthorizedException>());
    expect(repository.currentStatus, AuthStatus.unauthenticated);
    expect(secureStorage.values, isEmpty);
  });

  test('signOut revokes the server session and clears local state', () async {
    api.signInResult = successfulSignIn();
    await repository.signIn(email: 'demo@example.com', password: 'password1');

    await repository.signOut();

    expect(api.signOutCalls, 1);
    expect(repository.currentStatus, AuthStatus.unauthenticated);
    expect(repository.currentUser, isNull);
    expect(secureStorage.values, isEmpty);
    expect(keyValueStorage.getString(StorageKeys.currentUser), isNull);
  });
}
