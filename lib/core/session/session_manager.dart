import 'dart:async';

import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:dio/dio.dart';

enum SessionStatus { unknown, active, none }

final class SessionManager {
  SessionManager({
    required AppConfig config,
    required this._storage,
    Dio? tokenClient,
    this._logger = const AppLogger('SessionManager'),
  }) : _config = config,
       _tokenClient =
           tokenClient ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 20),
               headers: const {'Accept': 'application/json'},
             ),
           );

  final AppConfig _config;
  final SecureStorage _storage;
  final Dio _tokenClient;
  final AppLogger _logger;

  final _statusController = StreamController<SessionStatus>.broadcast();

  AuthTokens? _tokens;
  SessionStatus _status = SessionStatus.unknown;
  Future<String?>? _pendingRefresh;

  SessionStatus get status => _status;

  Stream<SessionStatus> get statusStream => _statusController.stream;

  String? get accessToken => _tokens?.accessToken;

  bool get hasValidAccessToken {
    final tokens = _tokens;
    return tokens != null && !tokens.isExpired;
  }

  Future<String?> validAccessToken() {
    final tokens = _tokens;
    if (tokens == null) return Future.value();
    if (!tokens.isExpired) return Future.value(tokens.accessToken);

    _logger.debug('Access token expired, refreshing before request');
    return refreshAccessToken();
  }

  Future<void> restore() async {
    final accessToken = await _storage.read(StorageKeys.accessToken);
    final refreshToken = await _storage.read(StorageKeys.refreshToken);

    if (accessToken == null || refreshToken == null) {
      _setStatus(SessionStatus.none);
      return;
    }

    final expiryRaw = await _storage.read(StorageKeys.accessTokenExpiry);
    _tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiryRaw == null ? null : DateTime.tryParse(expiryRaw),
    );
    _setStatus(SessionStatus.active);
  }

  Future<void> start(AuthTokens tokens) async {
    _tokens = tokens;
    await _persist(tokens);
    _setStatus(SessionStatus.active);
  }

  Future<void> end() async {
    _tokens = null;
    await _storage.delete(StorageKeys.accessToken);
    await _storage.delete(StorageKeys.refreshToken);
    await _storage.delete(StorageKeys.accessTokenExpiry);
    _setStatus(SessionStatus.none);
  }

  Future<String?> refreshAccessToken() {
    final pending = _pendingRefresh;
    if (pending != null) return pending;

    final refresh = _performRefresh().whenComplete(() {
      _pendingRefresh = null;
    });
    _pendingRefresh = refresh;
    return refresh;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = _tokens?.refreshToken;
    if (refreshToken == null) {
      await end();
      return null;
    }

    try {
      final response = await _tokenClient.post<Map<String, dynamic>>(
        _config.authEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final body = response.data;
      if (body == null) throw StateError('Empty refresh response');

      final tokens = AuthTokens.fromJson(
        body,
        fallbackRefreshToken: refreshToken,
      );
      _tokens = tokens;
      await _persist(tokens);
      _logger.info('Access token refreshed');
      return tokens.accessToken;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 400 || statusCode == 401) {
        _logger.warning('Refresh token rejected, ending session');
        await end();
      } else {
        _logger.warning('Token refresh failed transiently', error);
      }
      return null;
    } on Exception catch (error) {
      _logger.error('Unexpected error refreshing token', error);
      return null;
    }
  }

  Future<void> _persist(AuthTokens tokens) async {
    await _storage.write(StorageKeys.accessToken, tokens.accessToken);
    await _storage.write(StorageKeys.refreshToken, tokens.refreshToken);
    final expiresAt = tokens.expiresAt;
    if (expiresAt != null) {
      await _storage.write(
        StorageKeys.accessTokenExpiry,
        expiresAt.toIso8601String(),
      );
    } else {
      await _storage.delete(StorageKeys.accessTokenExpiry);
    }
  }

  void _setStatus(SessionStatus value) {
    if (_status == value) return;
    _status = value;
    _statusController.add(value);
  }

  void dispose() {
    unawaited(_statusController.close());
  }
}
