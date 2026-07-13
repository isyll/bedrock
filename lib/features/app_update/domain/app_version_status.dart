final class AppVersionStatus {
  const AppVersionStatus({
    required this.minimumBuild,
    required this.latestBuild,
  });

  factory AppVersionStatus.fromJson(Map<String, dynamic> json) => .new(
    minimumBuild: _readBuild(json['minimum_build']),
    latestBuild: _readBuild(json['latest_build']),
  );

  final int minimumBuild;
  final int latestBuild;

  UpdateRequirement requirementFor(int currentBuild) {
    if (currentBuild < minimumBuild) return .required;
    if (currentBuild < latestBuild) return .available;
    return .none;
  }

  static int _readBuild(Object? value) => switch (value) {
    final int number => number,
    final String text => .tryParse(text) ?? 0,
    _ => 0,
  };
}

enum UpdateRequirement { none, available, required }
