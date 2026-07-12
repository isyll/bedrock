import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/features/app_update/data/app_version_api.dart';
import 'package:bedrock/features/app_update/domain/app_version_status.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/user.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:bedrock/services/device/device_info_service.dart';
import 'package:bedrock/services/store/store_service.dart';
import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';

const testDeviceInfo = DeviceInfo(
  deviceId: 'test-device-id',
  platform: 'android',
  osVersion: '15',
  model: 'Pixel 9',
  manufacturer: 'Google',
  appVersion: '1.2.3',
  buildNumber: '42',
);

final class FakeDeviceInfoService implements DeviceInfoService {
  const FakeDeviceInfoService([this.deviceInfo = testDeviceInfo]);

  final DeviceInfo deviceInfo;

  @override
  DeviceInfo get info => deviceInfo;

  @override
  Future<DeviceInfo> load() async => deviceInfo;
}

ResponseBody jsonResponseBody(Object? body, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

DioException unauthorizedDioException() {
  final options = RequestOptions(path: '/v1/auth/login');
  return .new(
    requestOptions: options,
    type: .badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 401,
      data: {'message': 'Invalid credentials'},
    ),
  );
}

final class FakeStoreService implements StoreService {
  int openListingCalls = 0;
  int requestReviewCalls = 0;
  bool reviewAvailable = true;

  @override
  Future<void> openListing() async => openListingCalls++;

  @override
  Future<bool> requestReview() async {
    requestReviewCalls++;
    return reviewAvailable;
  }
}

final class ScriptedVersionApi implements AppVersionApi {
  ScriptedVersionApi(this.result);

  Result<AppVersionStatus> result;
  int fetchCalls = 0;

  @override
  Future<Result<AppVersionStatus>> fetchStatus() async {
    fetchCalls++;
    return result;
  }
}

final class FakeBiometricsService implements BiometricsService {
  FakeBiometricsService({
    this.supported = true,
    this.authResult = .success,
  });

  bool supported;
  BiometricAuthResult authResult;
  int authenticateCalls = 0;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    authenticateCalls++;
    return authResult;
  }

  @override
  Future<List<BiometricType>> enrolledBiometrics() async =>
      supported ? const [.strong] : const [];

  @override
  Future<bool> isSupported() async => supported;
}

final class InMemoryKeyValueStorage implements KeyValueStorage {
  InMemoryKeyValueStorage([Map<String, Object>? seed]) : values = {...?seed};

  final Map<String, Object> values;

  @override
  Future<void> clear() async => values.clear();

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String>? getStringList(String key) => values[key] as List<String>?;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async => values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => values[key] = value;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      values[key] = value;
}

final class InMemorySecureStorage implements SecureStorage {
  final values = <String, String>{};

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

final class ScriptedHttpAdapter implements HttpClientAdapter {
  ScriptedHttpAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  int requestCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestCount++;
    return handler(options);
  }
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
  DeviceInfo? lastSignInDevice;
  int signOutCalls = 0;

  @override
  Future<User> fetchProfile() async => profile ?? demoUser;

  @override
  Future<SignInResult> signIn({
    required String email,
    required String password,
    required DeviceInfo device,
  }) async {
    lastSignInDevice = device;
    final error = signInError;
    if (error != null) throw error;
    return signInResult!;
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}
