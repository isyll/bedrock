import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:in_app_review/in_app_review.dart';

class StoreService {
  StoreService({
    required this._config,
    InAppReview? inAppReview,
    this._logger = const .new('StoreService'),
  }) : _inAppReview = inAppReview ?? InAppReview.instance;

  final AppConfig _config;
  final InAppReview _inAppReview;
  final AppLogger _logger;

  Future<void> openListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: _config.appStoreId.isEmpty ? null : _config.appStoreId,
      );
    } on Exception catch (error) {
      _logger.warning('Failed to open the store listing', error);
    }
  }

  Future<bool> requestReview() async {
    try {
      if (!await _inAppReview.isAvailable()) return false;
      await _inAppReview.requestReview();
      return true;
    } on Exception catch (error) {
      _logger.warning('Failed to request an in-app review', error);
      return false;
    }
  }
}
