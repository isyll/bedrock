part of 'app_update_cubit.dart';

final class AppUpdateState extends Equatable {
  const AppUpdateState({this.availableVersion});

  final String? availableVersion;

  bool get updateAvailable => availableVersion != null;

  @override
  List<Object?> get props => [availableVersion];
}
