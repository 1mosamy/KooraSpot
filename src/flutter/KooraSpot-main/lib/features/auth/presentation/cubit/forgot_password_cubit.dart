import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/forgot_password_repository.dart';

part 'forgot_password_state.dart';

/// Manages the forgot-password → verify OTP → reset password flow.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepository _repository;

  ForgotPasswordCubit({required ForgotPasswordRepository repository})
      : _repository = repository,
        super(const ForgotPasswordInitial());

  String _email = '';
  String _otpCode = '';

  String get email => _email;
  String get otpCode => _otpCode;

  Future<void> sendOtp(String email) async {
    _email = email;
    emit(const ForgotPasswordLoading());
    try {
      await _repository.sendOtp(email);
      emit(const OtpSent());
    } catch (e) {
      emit(ForgotPasswordFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> resendOtp() async {
    if (_email.isEmpty) return;
    emit(const ForgotPasswordLoading());
    try {
      await _repository.sendOtp(_email);
      emit(const OtpSent());
    } catch (e) {
      emit(ForgotPasswordFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    _otpCode = otpCode;
    emit(const ForgotPasswordLoading());
    try {
      await _repository.verifyOtp(email: _email, otpCode: otpCode);
      emit(const OtpVerified());
    } catch (e) {
      emit(ForgotPasswordFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const ForgotPasswordLoading());
    try {
      await _repository.resetPassword(
        email: _email,
        otpCode: _otpCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(ForgotPasswordFailure(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Resets the cubit state so the flow can be restarted.
  void reset() {
    _email = '';
    _otpCode = '';
    emit(const ForgotPasswordInitial());
  }
}
