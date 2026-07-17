import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late SessionManager session;
  late AuthRepository repository;

  setUp(() async {
    final api = ScriptedAuthApi(
      signInResult: .new(
        user: ScriptedAuthApi.demoUser,
        tokens: .new(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: .now().toUtc().add(const .new(hours: 1)),
        ),
      ),
    );
    session = .new(
      config: _config,
      storage: InMemorySecureStorage(),
    );
    repository = .new(
      api: api,
      session: session,
      storage: InMemoryKeyValueStorage(),
      deviceInfoService: const FakeDeviceInfoService(),
    );
    await repository.signIn(email: 'demo@example.com', password: 'password1');
  });

  tearDown(() => session.dispose());

  test('starts from the repository snapshot', () {
    final bloc = SessionBloc(authRepository: repository);
    addTearDown(bloc.close);

    expect(bloc.state.isAuthenticated, isTrue);
    expect(bloc.state.user, ScriptedAuthApi.demoUser);
    expect(bloc.state.expired, isFalse);
  });

  test('flags expiry when the session ends without a sign out', () async {
    final bloc = SessionBloc(authRepository: repository);
    addTearDown(bloc.close);

    await session.end();
    await pumpEventQueue();

    expect(bloc.state.isAuthenticated, isFalse);
    expect(bloc.state.expired, isTrue);
  });

  test('does not flag expiry on an explicit sign out', () async {
    final bloc = SessionBloc(authRepository: repository);
    addTearDown(bloc.close);

    bloc.add(const SessionSignOutRequested());
    await pumpEventQueue();

    expect(bloc.state.isAuthenticated, isFalse);
    expect(bloc.state.expired, isFalse);
  });
}

const _config = AppConfig(
  flavor: .dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);
