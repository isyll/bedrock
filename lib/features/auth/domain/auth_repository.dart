import 'dart:convert';

import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/core/network/exception_mapper.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/user.dart';
import 'package:dio/dio.dart';

final class AuthRepository {
  AuthRepository({
    required this._api,
    required this._session,
    required this._storage,
    this._logger = const AppLogger('AuthRepository'),
  });

  final AuthApi _api;
  final SessionManager _session;
  final KeyValueStorage _storage;
  final AppLogger _logger;

  User? _currentUser;

  AuthStatus get currentStatus => _mapStatus(_session.status);

  User? get currentUser => _currentUser;

  Stream<AuthStatus> get status => _session.statusStream.map(_mapStatus);

  Future<Result<User>> refreshProfile() async {
    try {
      final user = await _api.fetchProfile();
      _currentUser = user;
      await _cacheUser(user);
      return .success(user);
    } on DioException catch (error) {
      return .failure(mapDioException(error));
    }
  }

  Future<void> restore() async {
    await _session.restore();
    if (_session.status == .active) {
      _currentUser = _readCachedUser();
    }
  }

  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _api.signIn(email: email, password: password);
      _currentUser = result.user;
      await _cacheUser(result.user);
      await _session.start(result.tokens);
      return .success(result.user);
    } on DioException catch (error) {
      return .failure(mapDioException(error));
    } on Object catch (error, stackTrace) {
      return .failure(
        UnexpectedException(
          'Sign in failed unexpectedly',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> signOut() async {
    await _revokeServerSession();
    _currentUser = null;
    await _storage.remove(StorageKeys.currentUser);
    await _session.end();
  }

  Future<void> _cacheUser(User user) =>
      _storage.setString(StorageKeys.currentUser, jsonEncode(user.toJson()));

  AuthStatus _mapStatus(SessionStatus status) => switch (status) {
    .unknown => .unknown,
    .active => .authenticated,
    .none => .unauthenticated,
  };

  User? _readCachedUser() {
    final raw = _storage.getString(StorageKeys.currentUser);
    if (raw == null) return null;
    try {
      return .fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<void> _revokeServerSession() async {
    try {
      await _api.signOut();
    } on DioException catch (error) {
      _logger.warning('Server-side sign out failed, ending locally', error);
    }
  }
}

enum AuthStatus { unknown, authenticated, unauthenticated }
