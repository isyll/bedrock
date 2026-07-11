import 'package:bedrock/core/logging/app_logger.dart';
import 'package:flutter/widgets.dart';

final class AppRouteObserver extends NavigatorObserver {
  AppRouteObserver({this._logger = const .new('Router')});

  final AppLogger _logger;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('pop', route, previousRoute);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('push', route, previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('remove', route, previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _log('replace', newRoute, oldRoute);

  void _log(String action, Route<dynamic>? route, Route<dynamic>? previous) =>
      _logger.debug(
        '$action: ${previous?.settings.name ?? '?'} '
        '-> ${route?.settings.name ?? '?'}',
      );
}
