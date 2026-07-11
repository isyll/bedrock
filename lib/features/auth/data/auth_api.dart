import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/network/api_client.dart';
import 'package:bedrock/core/network/interceptors/auth_interceptor.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/features/auth/domain/user.dart';
import 'package:dio/dio.dart';

final class SignInResult {
  const SignInResult({required this.user, required this.tokens});

  final User user;
  final AuthTokens tokens;
}

abstract interface class AuthApi {
  Future<SignInResult> signIn({
    required String email,
    required String password,
  });

  Future<User> fetchProfile();

  Future<void> signOut();
}

final class HttpAuthApi implements AuthApi {
  const HttpAuthApi({required this._client, required this._config});

  final ApiClient _client;
  final AppConfig _config;

  @override
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      _config.authEndpoints.signIn,
      data: {'email': email, 'password': password},
      options: Options(extra: const {AuthInterceptor.skipAuthKey: true}),
    );

    final body = response.data!;
    final tokens = AuthTokens.fromJson(body);
    final user = await _resolveUser(body, tokens);

    return SignInResult(user: user, tokens: tokens);
  }

  @override
  Future<User> fetchProfile() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      _config.authEndpoints.profile,
    );
    return User.fromJson(response.data!);
  }

  @override
  Future<void> signOut() async {
    await _client.dio.post<void>(_config.authEndpoints.signOut);
  }

  Future<User> _resolveUser(
    Map<String, dynamic> body,
    AuthTokens tokens,
  ) async {
    final embedded = AuthTokens.unwrapPayload(body)['user'];
    if (embedded is Map<String, dynamic>) return User.fromJson(embedded);

    final response = await _client.dio.get<Map<String, dynamic>>(
      _config.authEndpoints.profile,
      options: Options(
        headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
        extra: const {AuthInterceptor.skipAuthKey: true},
      ),
    );
    return User.fromJson(response.data!);
  }
}

final class FakeAuthApi implements AuthApi {
  const FakeAuthApi();

  static const _demoUser = User(
    id: '1',
    email: 'demo@example.com',
    name: 'Demo User',
  );

  @override
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return SignInResult(
      user: User(id: '1', email: email, name: 'Demo User'),
      tokens: AuthTokens(
        accessToken: 'fake-access-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'fake-refresh-token',
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<User> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _demoUser;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
