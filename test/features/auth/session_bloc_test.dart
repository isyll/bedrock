import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _config = AppConfig(
  flavor: AppFlavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);

void main() {
  late SessionManager session;
  late AuthRepository repository;

  setUp(() async {
    final api = ScriptedAuthApi(
      signInResult: SignInResult(
        user: ScriptedAuthApi.demoUser,
        tokens: AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      ),
    );
    session = SessionManager(
      config: _config,
      storage: InMemorySecureStorage(),
    );
    repository = AuthRepository(
      api: api,
      session: session,
      storage: InMemoryKeyValueStorage(),
    );
    await repository.signIn(email: 'demo@example.com', password: 'password1');
  });

  tearDown(() {
    session.dispose();
  });

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
