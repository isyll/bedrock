part of 'session_bloc.dart';

final class SessionState extends Equatable {
  const SessionState({required this.status, this.user, this.expired = false});

  final AuthStatus status;
  final User? user;
  final bool expired;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, expired];
}
