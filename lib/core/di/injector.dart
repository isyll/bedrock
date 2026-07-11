import 'package:bedrock/app/router/app_router.dart';
import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/network/api_client.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/core/storage/key_value_storage.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/features/auth/data/auth_api.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:bedrock/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:bedrock/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:bedrock/services/crash/crash_reporter.dart';
import 'package:bedrock/services/notifications/push_notifications_service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies(
  AppConfig config, {
  CrashReporter? crashReporter,
}) async {
  final keyValueStorage = await KeyValueStorage.create();

  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<CrashReporter>(crashReporter ?? CrashReporter())
    ..registerSingleton<KeyValueStorage>(keyValueStorage)
    ..registerSingleton<SecureStorage>(const SecureStorage())
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(storage: getIt()))
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(storage: getIt()))
    ..registerLazySingleton<SessionManager>(
      () => SessionManager(config: getIt(), storage: getIt()),
      dispose: (manager) => manager.dispose(),
    )
    ..registerLazySingleton<ApiClientFactory>(
      () => ApiClientFactory(
        config: getIt(),
        session: getIt(),
        localeResolver: () => getIt<LocaleCubit>().languageCode,
      ),
    )
    ..registerLazySingleton<ApiClient>(
      () => getIt<ApiClientFactory>().backend(),
      dispose: (client) => client.close(),
    )
    ..registerLazySingleton<AuthApi>(
      () => config.useFakeAuth
          ? const FakeAuthApi()
          : HttpAuthApi(client: getIt(), config: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(api: getIt(), session: getIt(), storage: getIt()),
    )
    ..registerLazySingleton<SessionBloc>(
      () => SessionBloc(authRepository: getIt()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<AppRouter>(
      () => AppRouter(sessionBloc: getIt()),
      dispose: (router) => router.dispose(),
    )
    ..registerLazySingleton<PushNotificationsService>(
      () => PushNotificationsService(
        onOpenRoute: (route) => getIt<AppRouter>().router.go(route),
      ),
      dispose: (service) => service.dispose(),
    );
}
