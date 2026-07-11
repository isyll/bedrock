import 'package:equatable/equatable.dart';

final class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory AuthTokens.fromOAuthResponse(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as num?;
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: expiresIn == null
          ? null
          : DateTime.now().add(Duration(seconds: expiresIn.toInt())),
    );
  }

  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 30)));
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
