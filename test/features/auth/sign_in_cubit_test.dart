import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late ScriptedAuthApi api;
  late SessionManager session;
  late AuthRepository repository;

  setUp(() {
    api = .new();
    session = .new(
      config: _config,
      storage: InMemorySecureStorage(),
    );
    repository = .new(
      api: api,
      session: session,
      storage: InMemoryKeyValueStorage(),
    );
  });

  tearDown(() => session.dispose());

  group('SignInCubit', () {
    blocTest<SignInCubit, SignInState>(
      'emits submitting then success on valid credentials',
      build: () => .new(authRepository: repository),
      setUp: () => api.signInResult = .new(
        user: ScriptedAuthApi.demoUser,
        tokens: .new(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: .now().toUtc().add(const .new(hours: 1)),
        ),
      ),
      act: (cubit) =>
          cubit.submit(email: 'demo@example.com', password: 'password1'),
      expect: () => <SignInState>[
        const .new(isSubmitting: true),
        const .new(isSuccess: true),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits submitting then a localized failure on rejection',
      build: () => .new(authRepository: repository),
      setUp: () => api.signInError = unauthorizedDioException(),
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
      build: () => .new(authRepository: repository),
      seed: () => const .new(isSubmitting: true),
      act: (cubit) =>
          cubit.submit(email: 'demo@example.com', password: 'password1'),
      expect: List.empty,
    );
  });
}

const _config = AppConfig(
  flavor: .dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);
