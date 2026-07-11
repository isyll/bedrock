import 'dart:async';

import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/user.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';

final class InMemorySecureStorage implements SecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<void> deleteAll() async => values.clear();
}

final class InMemoryKeyValueStorage implements KeyValueStorage {
  InMemoryKeyValueStorage([Map<String, Object>? seed]) : values = {...?seed};

  final Map<String, Object> values;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  List<String>? getStringList(String key) => values[key] as List<String>?;

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async => values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

final class ScriptedAuthApi implements AuthApi {
  ScriptedAuthApi({this.signInResult, this.signInError, this.profile});

  static const demoUser = User(
    id: '42',
    email: 'demo@example.com',
    name: 'Demo User',
  );

  SignInResult? signInResult;
  Exception? signInError;
  User? profile;
  int signOutCalls = 0;

  @override
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    final error = signInError;
    if (error != null) throw error;
    return signInResult!;
  }

  @override
  Future<User> fetchProfile() async => profile ?? demoUser;

  @override
  Future<void> signOut() async => signOutCalls++;
}

final class FakeBiometricsService implements BiometricsService {
  FakeBiometricsService({
    this.supported = true,
    this.authResult = BiometricAuthResult.success,
  });

  bool supported;
  BiometricAuthResult authResult;
  int authenticateCalls = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<List<BiometricType>> enrolledBiometrics() async =>
      supported ? const [BiometricType.strong] : const [];

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    authenticateCalls++;
    return authResult;
  }
}

DioException unauthorizedDioException() {
  final options = RequestOptions(path: '/auth/login');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 401,
      data: {'message': 'Invalid credentials'},
    ),
  );
}
