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
}

final class HttpAuthApi implements AuthApi {
  const HttpAuthApi({required this._client, required this._config});

  static const _profilePath = '/me';

  final ApiClient _client;
  final AppConfig _config;

  @override
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    final tokenResponse = await _client.dio.post<Map<String, dynamic>>(
      _config.tokenEndpoint,
      data: {
        'grant_type': 'password',
        'username': email,
        'password': password,
        if (_config.oauthClientId != null) 'client_id': _config.oauthClientId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        extra: const {AuthInterceptor.skipAuthKey: true},
      ),
    );

    final tokens = AuthTokens.fromOAuthResponse(tokenResponse.data!);

    final profileResponse = await _client.dio.get<Map<String, dynamic>>(
      _profilePath,
      options: Options(
        headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
        extra: const {AuthInterceptor.skipAuthKey: true},
      ),
    );

    return SignInResult(
      user: User.fromJson(profileResponse.data!),
      tokens: tokens,
    );
  }

  @override
  Future<User> fetchProfile() async {
    final response = await _client.dio.get<Map<String, dynamic>>(_profilePath);
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
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<User> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _demoUser;
  }
}
