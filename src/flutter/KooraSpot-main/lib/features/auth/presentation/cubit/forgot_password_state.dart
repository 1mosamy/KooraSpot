part of 'forgot_password_cubit.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class OtpSent extends ForgotPasswordState {
  const OtpSent();
}

class OtpVerified extends ForgotPasswordState {
  const OtpVerified();
}

class PasswordResetSuccess extends ForgotPasswordState {
  const PasswordResetSuccess();
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;
  const ForgotPasswordFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
