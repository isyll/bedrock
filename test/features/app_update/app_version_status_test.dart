import 'package:bedrock/features/app_update/domain/app_version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppVersionStatus.fromJson', () {
    test('parses integer builds', () {
      final status = AppVersionStatus.fromJson(const {
        'minimum_build': 10,
        'latest_build': 20,
      });

      expect(status.minimumBuild, 10);
      expect(status.latestBuild, 20);
    });

    test('parses string builds and defaults missing values to zero', () {
      final status = AppVersionStatus.fromJson(const {
        'minimum_build': '15',
      });

      expect(status.minimumBuild, 15);
      expect(status.latestBuild, 0);
    });
  });

  group('AppVersionStatus.requirementFor', () {
    const status = AppVersionStatus(minimumBuild: 10, latestBuild: 20);

    test(
      'requires an update below the minimum build',
      () => expect(status.requirementFor(9), UpdateRequirement.required),
    );

    test('offers an update between minimum and latest', () {
      expect(status.requirementFor(10), UpdateRequirement.available);
      expect(status.requirementFor(19), UpdateRequirement.available);
    });

    test('reports none at or above the latest build', () {
      expect(status.requirementFor(20), UpdateRequirement.none);
      expect(status.requirementFor(21), UpdateRequirement.none);
    });
  });
}
