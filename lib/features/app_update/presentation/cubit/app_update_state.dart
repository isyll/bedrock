part of 'app_update_cubit.dart';

final class AppUpdateState extends Equatable {
  const AppUpdateState({this.availableVersion});

  final String? availableVersion;

  @override
  List<Object?> get props => [availableVersion];

  bool get updateAvailable => availableVersion != null;
}
