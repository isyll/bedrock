import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthTokens.fromJson', () {
    test('parses tokens with an ISO 8601 expires_at', () {
      final tokens = AuthTokens.fromJson(const {
        'access_token': 'access',
        'refresh_token': 'refresh',
        'expires_at': '2030-01-01T12:00:00Z',
      });

      expect(tokens.accessToken, 'access');
      expect(tokens.refreshToken, 'refresh');
      expect(tokens.expiresAt, DateTime.utc(2030, 1, 1, 12));
    });

    test('parses expired_at as an alias of expires_at', () {
      final tokens = AuthTokens.fromJson(const {
        'access_token': 'access',
        'refresh_token': 'refresh',
        'expired_at': '2030-06-15T00:00:00Z',
      });

      expect(tokens.expiresAt, DateTime.utc(2030, 6, 15));
    });

    test('parses epoch seconds and epoch milliseconds', () {
      final seconds = AuthTokens.fromJson(const {
        'access_token': 'a',
        'refresh_token': 'r',
        'expires_at': 1893456000,
      });
      final millis = AuthTokens.fromJson(const {
        'access_token': 'a',
        'refresh_token': 'r',
        'expires_at': 1893456000000,
      });

      expect(seconds.expiresAt, DateTime.utc(2030));
      expect(millis.expiresAt, DateTime.utc(2030));
    });

    test('falls back to expires_in when expires_at is absent', () {
      final before = DateTime.now().toUtc();
      final tokens = AuthTokens.fromJson(const {
        'access_token': 'a',
        'refresh_token': 'r',
        'expires_in': 3600,
      });
      final after = DateTime.now().toUtc();

      expect(
        tokens.expiresAt,
        isNotNull,
      );
      expect(
        tokens.expiresAt!.isBefore(before.add(const Duration(hours: 1))),
        isFalse,
      );
      expect(
        tokens.expiresAt!.isAfter(after.add(const Duration(hours: 1))),
        isFalse,
      );
    });

    test('accepts a token alias and unwraps a data envelope', () {
      final tokens = AuthTokens.fromJson(const {
        'data': {'token': 'wrapped', 'refresh_token': 'refresh'},
      });

      expect(tokens.accessToken, 'wrapped');
      expect(tokens.expiresAt, isNull);
    });

    test('keeps the previous refresh token when rotation is absent', () {
      final tokens = AuthTokens.fromJson(
        const {'access_token': 'new-access'},
        fallbackRefreshToken: 'old-refresh',
      );

      expect(tokens.refreshToken, 'old-refresh');
    });

    test('throws when the access token is missing', () {
      expect(
        () => AuthTokens.fromJson(const {'refresh_token': 'r'}),
        throwsFormatException,
      );
    });

    test('throws when no refresh token can be resolved', () {
      expect(
        () => AuthTokens.fromJson(const {'access_token': 'a'}),
        throwsFormatException,
      );
    });
  });

  group('expiry', () {
    AuthTokens tokensExpiringIn(Duration duration) => AuthTokens(
      accessToken: 'a',
      refreshToken: 'r',
      expiresAt: DateTime.now().toUtc().add(duration),
    );

    test('never expires without an expiry timestamp', () {
      const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

      expect(tokens.isExpired, isFalse);
      expect(tokens.expiresWithin(const Duration(days: 365)), isFalse);
      expect(tokens.timeUntilExpiry, isNull);
    });

    test('reports expired for a past timestamp', () {
      expect(tokensExpiringIn(const Duration(hours: -1)).isExpired, isTrue);
    });

    test('treats tokens inside the leeway window as expired', () {
      expect(tokensExpiringIn(const Duration(seconds: 10)).isExpired, isTrue);
    });

    test('reports valid outside the leeway window', () {
      expect(tokensExpiringIn(const Duration(minutes: 5)).isExpired, isFalse);
    });

    test('expiresWithin looks ahead by the given duration', () {
      final tokens = tokensExpiringIn(const Duration(minutes: 5));

      expect(tokens.expiresWithin(const Duration(minutes: 10)), isTrue);
      expect(tokens.expiresWithin(const Duration(minutes: 1)), isFalse);
    });

    test('timeUntilExpiry clamps to zero once past', () {
      expect(
        tokensExpiringIn(const Duration(hours: -1)).timeUntilExpiry,
        Duration.zero,
      );
    });
  });
}
