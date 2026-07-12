import 'package:equatable/equatable.dart';

final class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory AuthTokens.fromJson(
    Map<String, dynamic> json, {
    String? fallbackRefreshToken,
  }) {
    final payload = unwrapPayload(json);
    final accessToken =
        (payload['access_token'] ?? payload['token']) as String?;
    if (accessToken == null) {
      throw const FormatException('Auth response is missing an access token');
    }

    final refreshToken =
        (payload['refresh_token'] as String?) ?? fallbackRefreshToken;
    if (refreshToken == null) {
      throw const FormatException('Auth response is missing a refresh token');
    }

    return .new(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: parseExpiry(payload),
    );
  }

  static const expiryLeeway = Duration(seconds: 30);

  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  bool get isExpired => expiresWithin(.zero);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];

  Duration? get timeUntilExpiry {
    final expiry = expiresAt;
    if (expiry == null) return null;
    final remaining = expiry.difference(.now().toUtc());
    return remaining.isNegative ? .zero : remaining;
  }

  bool expiresWithin(Duration duration) {
    final expiry = expiresAt;
    if (expiry == null) return false;
    final threshold = expiry.subtract(expiryLeeway).subtract(duration);
    return !DateTime.now().toUtc().isBefore(threshold);
  }

  static DateTime? parseExpiry(Map<String, dynamic> json) {
    final expiresAt = json['expires_at'] ?? json['expired_at'];

    return switch (expiresAt) {
      final String value => .tryParse(value)?.toUtc(),
      final num value => _epochToDateTime(value),
      _ => switch (json['expires_in']) {
        final num value => .now().toUtc().add(
          .new(seconds: value.toInt()),
        ),
        final String value => .now().toUtc().add(
          .new(seconds: .tryParse(value) ?? 0),
        ),
        _ => null,
      },
    };
  }

  static Map<String, dynamic> unwrapPayload(Map<String, dynamic> json) {
    if (json['access_token'] != null || json['token'] != null) return json;
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static DateTime _epochToDateTime(num value) {
    const millisThreshold = 100000000000;
    final millis = value >= millisThreshold
        ? value.toInt()
        : value.toInt() * 1000;
    return .fromMillisecondsSinceEpoch(millis, isUtc: true);
  }
}
