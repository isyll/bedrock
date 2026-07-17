import 'package:equatable/equatable.dart';

final class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null) {
      throw const FormatException('User response is missing an id');
    }

    return .new(
      id: id.toString(),
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  String get displayName {
    final value = name;
    if (value != null && value.isNotEmpty) return value;
    return email;
  }

  @override
  List<Object?> get props => [id, email, name, avatarUrl];

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar_url': avatarUrl,
  };
}
