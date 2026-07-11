import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/services/permissions/app_permission.dart';
import 'package:bedrock/services/permissions/permissions_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

final class MediaPickerService {
  MediaPickerService({required this._permissions});

  static const _defaultImageQuality = 85;
  static const _defaultMaxDimension = 2048.0;

  final PermissionsService _permissions;
  final _imagePicker = ImagePicker();

  Future<Result<PickedFile?>> pickFile({
    List<XTypeGroup> typeGroups = const [],
  }) {
    return _guarded(() async {
      final file = await openFile(acceptedTypeGroups: typeGroups);
      if (file == null) return null;
      return PickedFile(path: file.path, name: file.name);
    });
  }

  Future<Result<List<PickedFile>>> pickFiles({
    List<XTypeGroup> typeGroups = const [],
  }) {
    return _guarded(() async {
      final files = await openFiles(acceptedTypeGroups: typeGroups);
      return files
          .map((file) => PickedFile(path: file.path, name: file.name))
          .toList();
    });
  }

  Future<Result<PickedFile?>> pickImageFromGallery() {
    return _guarded(() async {
      final file = await _imagePicker.pickImage(
        source: .gallery,
        imageQuality: _defaultImageQuality,
        maxWidth: _defaultMaxDimension,
        maxHeight: _defaultMaxDimension,
      );
      return _toPickedFile(file);
    });
  }

  Future<Result<List<PickedFile>>> pickImagesFromGallery({int? limit}) {
    return _guarded(() async {
      final files = await _imagePicker.pickMultiImage(
        imageQuality: _defaultImageQuality,
        maxWidth: _defaultMaxDimension,
        maxHeight: _defaultMaxDimension,
        limit: limit,
      );
      return files
          .map((file) => PickedFile(path: file.path, name: file.name))
          .toList();
    });
  }

  Future<Result<PickedFile?>> takePhoto({
    CameraDevice preferredCamera = .rear,
  }) {
    return _guarded(() async {
      await _ensurePermission(.camera);
      final file = await _imagePicker.pickImage(
        source: .camera,
        preferredCameraDevice: preferredCamera,
        imageQuality: _defaultImageQuality,
        maxWidth: _defaultMaxDimension,
        maxHeight: _defaultMaxDimension,
      );
      return _toPickedFile(file);
    });
  }

  Future<void> _ensurePermission(AppPermission permission) async {
    final result = await _permissions.ensure(permission);
    if (result.isUsable) return;
    throw PermissionException(
      'Missing ${permission.name} permission',
      permanentlyDenied: result == .permanentlyDenied,
    );
  }

  Future<Result<T>> _guarded<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on AppException catch (error) {
      return Result.failure(error);
    } on PlatformException catch (error, stackTrace) {
      return Result.failure(
        UnexpectedException(
          'Media selection failed',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  PickedFile? _toPickedFile(XFile? file) {
    if (file == null) return null;
    return .new(path: file.path, name: file.name);
  }
}

final class PickedFile {
  const PickedFile({required this.path, required this.name});

  final String path;
  final String name;
}
