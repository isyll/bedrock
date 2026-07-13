part of 'app_update_cubit.dart';

final class AppUpdateState extends Equatable {
  const AppUpdateState({
    this.requirement = .none,
    this.latestBuild = 0,
    this.promptPending = false,
  });

  final UpdateRequirement requirement;
  final int latestBuild;
  final bool promptPending;

  @override
  List<Object> get props => [requirement, latestBuild, promptPending];

  bool get updateRequired => requirement == .required;

  AppUpdateState copyWith({
    UpdateRequirement? requirement,
    int? latestBuild,
    bool? promptPending,
  }) => .new(
    requirement: requirement ?? this.requirement,
    latestBuild: latestBuild ?? this.latestBuild,
    promptPending: promptPending ?? this.promptPending,
  );
}
