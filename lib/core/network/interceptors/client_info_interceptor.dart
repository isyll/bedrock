import 'package:bedrock/services/device/device_info.dart';
import 'package:dio/dio.dart';

final class ClientInfoInterceptor extends Interceptor {
  const ClientInfoInterceptor({required this._info});

  final DeviceInfo _info;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'X-App-Version': _info.appVersion,
      'X-Build-Number': _info.buildNumber,
      'X-Platform': _info.platform,
      'X-OS-Version': _info.osVersion,
      'X-Device-Id': _info.deviceId,
    });
    handler.next(options);
  }
}
