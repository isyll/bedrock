import 'dart:async';

import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/domain/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_event.dart';
part 'session_state.dart';

final class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(
        .new(
          status: authRepository.currentStatus,
          user: authRepository.currentUser,
        ),
      ) {
    on<SessionStatusChanged>(_onStatusChanged);
    on<SessionSignOutRequested>(_onSignOutRequested);

    _statusSubscription = _authRepository.status.listen(
      (status) => add(SessionStatusChanged(status)),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AuthStatus> _statusSubscription;

  bool _signOutRequested = false;

  @override
  Future<void> close() {
    unawaited(_statusSubscription.cancel());
    return super.close();
  }

  Future<void> _onSignOutRequested(
    SessionSignOutRequested event,
    Emitter<SessionState> emit,
  ) {
    _signOutRequested = true;
    return _authRepository.signOut();
  }

  void _onStatusChanged(
    SessionStatusChanged event,
    Emitter<SessionState> emit,
  ) {
    final previous = state.status;
    final expired =
        previous == .authenticated &&
        event.status == .unauthenticated &&
        !_signOutRequested;
    _signOutRequested = false;
    emit(
      .new(
        status: event.status,
        user: _authRepository.currentUser,
        expired: expired,
      ),
    );
  }
}
