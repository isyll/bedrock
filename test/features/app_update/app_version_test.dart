import 'package:bedrock/features/app_update/domain/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isVersionNewer', () {
    test('detects a newer major, minor, or patch', () {
      expect(isVersionNewer('2.0.0', '1.9.9'), isTrue);
      expect(isVersionNewer('1.3.0', '1.2.9'), isTrue);
      expect(isVersionNewer('1.2.4', '1.2.3'), isTrue);
    });

    test(
      'treats an equal version as not newer',
      () => expect(isVersionNewer('1.2.3', '1.2.3'), isFalse),
    );

    test('compares segments numerically, not lexically', () {
      expect(isVersionNewer('1.10.0', '1.9.0'), isTrue);
      expect(isVersionNewer('1.9.0', '1.10.0'), isFalse);
    });

    test('handles differing segment counts', () {
      expect(isVersionNewer('1.2', '1.2.0'), isFalse);
      expect(isVersionNewer('1.2.1', '1.2'), isTrue);
    });
  });
}
