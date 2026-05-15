part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthRegistering extends AuthState {
  const AuthRegistering();
}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Emitted when registration completes successfully.
/// [needsOtpVerification] is true when the backend response indicates
/// the user must verify their email before logging in.
class AuthRegistered extends AuthState {
  final String email;
  final bool needsOtpVerification;
  const AuthRegistered({required this.email, this.needsOtpVerification = false});
  @override
  List<Object?> get props => [email, needsOtpVerification];
}

// ── Email Verification States ─────────────────────────

class EmailVerificationLoading extends AuthState {
  const EmailVerificationLoading();
}

class EmailVerificationSuccess extends AuthState {
  const EmailVerificationSuccess();
}

class EmailVerificationFailure extends AuthState {
  final String message;
  const EmailVerificationFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

class ResendOtpLoading extends AuthState {
  const ResendOtpLoading();
}

class ResendOtpSuccess extends AuthState {
  const ResendOtpSuccess();
}

class ResendOtpFailure extends AuthState {
  final String message;
  const ResendOtpFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
