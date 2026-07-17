import 'dart:async';

import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/core/network/interceptors/client_info_interceptor.dart';
import 'package:bedrock/core/network/interceptors/locale_interceptor.dart';
import 'package:bedrock/core/network/network_timeouts.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:dio/dio.dart';

final class SessionManager {
  SessionManager({
    required AppConfig config,
    required this._storage,
    Dio? tokenClient,
    LocaleResolver? localeResolver,
    DeviceInfo? deviceInfo,
    this._logger = const .new('SessionManager'),
  }) : _config = config,
       _tokenClient =
           tokenClient ??
           .new(
             .new(
               baseUrl: config.apiBaseUrl,
               connectTimeout: NetworkTimeouts.connect,
               sendTimeout: NetworkTimeouts.send,
               receiveTimeout: NetworkTimeouts.receive,
               headers: const {'Accept': 'application/json'},
             ),
           ) {
    _tokenClient.interceptors.addAll([
      if (deviceInfo != null) ClientInfoInterceptor(info: deviceInfo),
      LocaleInterceptor(resolver: localeResolver),
    ]);
  }

  final AppConfig _config;
  final SecureStorage _storage;
  final Dio _tokenClient;
  final AppLogger _logger;

  final _statusController = StreamController<SessionStatus>.broadcast();

  AuthTokens? _tokens;
  SessionStatus _status = .unknown;
  Future<String?>? _pendingRefresh;

  String? get accessToken => _tokens?.accessToken;

  bool get hasValidAccessToken {
    final tokens = _tokens;
    return tokens != null && !tokens.isExpired;
  }

  SessionStatus get status => _status;

  Stream<SessionStatus> get statusStream => _statusController.stream;

  void dispose() => unawaited(_statusController.close());

  Future<void> end() async {
    _tokens = null;
    await _storage.delete(StorageKeys.accessToken);
    await _storage.delete(StorageKeys.refreshToken);
    await _storage.delete(StorageKeys.accessTokenExpiry);

    if (await _tokensStillPersisted()) {
      _logger.warning('Token deletion incomplete, clearing secure storage');
      await _storage.deleteAll();
    }

    _setStatus(.none);
  }

  Future<String?> refreshAccessToken() {
    final pending = _pendingRefresh;
    if (pending != null) return pending;

    final refresh = _performRefresh().whenComplete(
      () => _pendingRefresh = null,
    );
    _pendingRefresh = refresh;
    return refresh;
  }

  Future<void> restore() async {
    final accessToken = await _storage.read(StorageKeys.accessToken);
    final refreshToken = await _storage.read(StorageKeys.refreshToken);

    if (accessToken == null || refreshToken == null) {
      _setStatus(.none);
      return;
    }

    final expiryRaw = await _storage.read(StorageKeys.accessTokenExpiry);
    _tokens = .new(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiryRaw == null ? null : .tryParse(expiryRaw),
    );
    _setStatus(.active);
  }

  Future<void> start(AuthTokens tokens) async {
    _tokens = tokens;
    await _persist(tokens);
    _setStatus(.active);
  }

  Future<String?> validAccessToken() {
    final tokens = _tokens;
    if (tokens == null) return .value();
    if (!tokens.isExpired) return .value(tokens.accessToken);

    _logger.debug('Access token expired, refreshing before request');
    return refreshAccessToken();
  }

  Future<bool> _tokensStillPersisted() async {
    return await _storage.containsKey(StorageKeys.accessToken) ||
        await _storage.containsKey(StorageKeys.refreshToken);
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
}

enum SessionStatus { unknown, active, none }
