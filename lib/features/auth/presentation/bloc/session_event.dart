part of 'session_bloc.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionStatusChanged extends SessionEvent {
  const SessionStatusChanged(this.status);

  final AuthStatus status;
}

final class SessionSignOutRequested extends SessionEvent {
  const SessionSignOutRequested();
}
