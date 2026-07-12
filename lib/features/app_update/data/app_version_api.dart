import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/network/api_client.dart';
import 'package:bedrock/core/network/interceptors/auth_interceptor.dart';
import 'package:bedrock/features/app_update/domain/app_version_status.dart';
import 'package:dio/dio.dart';

class AppVersionApi {
  const AppVersionApi({required this._client, required this._config});

  final ApiClient _client;
  final AppConfig _config;

  Future<Result<AppVersionStatus>> fetchStatus() => _client.run((dio) async {
    final response = await dio.get<Map<String, dynamic>>(
      _config.versionEndpoint,
      options: Options(extra: const {AuthInterceptor.skipAuthKey: true}),
    );
    return AppVersionStatus.fromJson(response.data!);
  });
}
