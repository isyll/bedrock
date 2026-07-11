import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sign_in_state.dart';

final class SignInCubit extends Cubit<SignInState> {
  SignInCubit({required this._authRepository}) : super(const SignInState());

  final AuthRepository _authRepository;

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) return;
    emit(const SignInState(isSubmitting: true));

    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );

    result.fold(
      onSuccess: (_) => emit(const SignInState(isSuccess: true)),
      onFailure: (exception) => emit(SignInState(failure: exception)),
    );
  }
}
