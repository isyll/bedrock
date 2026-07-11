import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _config = AppConfig(
  flavor: AppFlavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);

void main() {
  late ScriptedAuthApi api;
  late SessionManager session;
  late AuthRepository repository;

  setUp(() {
    api = ScriptedAuthApi();
    session = SessionManager(
      config: _config,
      storage: InMemorySecureStorage(),
    );
    repository = AuthRepository(
      api: api,
      session: session,
      storage: InMemoryKeyValueStorage(),
    );
  });

  tearDown(() {
    session.dispose();
  });

  group('SignInCubit', () {
    blocTest<SignInCubit, SignInState>(
      'emits submitting then success on valid credentials',
      build: () => SignInCubit(authRepository: repository),
      setUp: () {
        api.signInResult = SignInResult(
          user: ScriptedAuthApi.demoUser,
          tokens: AuthTokens(
            accessToken: 'access',
            refreshToken: 'refresh',
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
        );
      },
      act: (cubit) =>
          cubit.submit(email: 'demo@example.com', password: 'password1'),
      expect: () => [
        const SignInState(isSubmitting: true),
        const SignInState(isSuccess: true),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits submitting then a localized failure on rejection',
      build: () => SignInCubit(authRepository: repository),
      setUp: () {
        api.signInError = unauthorizedDioException();
      },
      act: (cubit) =>
          cubit.submit(email: 'demo@example.com', password: 'wrong'),
      expect: () => [
        const SignInState(isSubmitting: true),
        isA<SignInState>()
            .having((state) => state.isSubmitting, 'isSubmitting', isFalse)
            .having(
              (state) => state.failure,
              'failure',
              isA<UnauthorizedException>(),
            ),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'ignores submissions while one is in flight',
      build: () => SignInCubit(authRepository: repository),
      seed: () => const SignInState(isSubmitting: true),
      act: (cubit) =>
          cubit.submit(email: 'demo@example.com', password: 'password1'),
      expect: List.empty,
    );
  });
}
