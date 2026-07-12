import 'package:bedrock/app/router/app_router.dart';
import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/network/api_client.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:bedrock/features/security/presentation/cubit/app_lock_cubit.dart';
import 'package:bedrock/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:bedrock/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:bedrock/services/biometrics/biometrics_service.dart';
import 'package:bedrock/services/crash/crash_reporter.dart';
import 'package:bedrock/services/location/location_service.dart';
import 'package:bedrock/services/media/media_picker_service.dart';
import 'package:bedrock/services/notifications/push_notifications_service.dart';
import 'package:bedrock/services/permissions/permissions_service.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = .instance;

Future<void> configureDependencies(
  AppConfig config, {
  CrashReporter? crashReporter,
}) async {
  final keyValueStorage = await KeyValueStorage.create();

  sl
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<CrashReporter>(crashReporter ?? .new())
    ..registerSingleton<KeyValueStorage>(keyValueStorage)
    ..registerSingleton<SecureStorage>(const .new())
    ..registerLazySingleton<ThemeCubit>(() => .new(storage: sl()))
    ..registerLazySingleton<LocaleCubit>(() => .new(storage: sl()))
    ..registerLazySingleton<BiometricsService>(BiometricsService.new)
    ..registerLazySingleton<AppLockCubit>(
      () => .new(storage: sl(), biometrics: sl()),
      dispose: (cubit) => cubit.close(),
    )
    ..registerLazySingleton<SessionManager>(
      () => .new(
        config: sl(),
        storage: sl(),
        localeResolver: () => sl<LocaleCubit>().languageCode,
      ),
      dispose: (manager) => manager.dispose(),
    )
    ..registerLazySingleton<ApiClientFactory>(
      () => .new(
        config: sl(),
        session: sl(),
        localeResolver: () => sl<LocaleCubit>().languageCode,
      ),
    )
    ..registerLazySingleton<ApiClient>(
      () => sl<ApiClientFactory>().backend(),
      dispose: (client) => client.close(),
    )
    ..registerLazySingleton<AuthApi>(
      () => config.useFakeAuth
          ? const FakeAuthApi()
          : HttpAuthApi(client: sl(), config: sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => .new(api: sl(), session: sl(), storage: sl()),
    )
    ..registerLazySingleton<SessionBloc>(
      () => .new(authRepository: sl()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<AppRouter>(
      () => .new(sessionBloc: sl()),
      dispose: (router) => router.dispose(),
    )
    ..registerLazySingleton<PushNotificationsService>(
      () => .new(
        onOpenRoute: (route) => sl<AppRouter>().router.go(route),
      ),
      dispose: (service) => service.dispose(),
    )
    ..registerLazySingleton<PermissionsService>(PermissionsService.new)
    ..registerLazySingleton<MediaPickerService>(
      () => .new(permissions: sl()),
    )
    ..registerLazySingleton<LocationService>(
      () => .new(permissions: sl()),
    );
}
