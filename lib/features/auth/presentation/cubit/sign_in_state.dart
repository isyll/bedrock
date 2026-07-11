part of 'sign_in_cubit.dart';

final class SignInState extends Equatable {
  const SignInState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.failure,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final AppException? failure;

  @override
  List<Object?> get props => [isSubmitting, isSuccess, failure];
}
