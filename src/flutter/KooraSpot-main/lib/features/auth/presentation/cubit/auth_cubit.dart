import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfileCubit? _profileCubit;

  AuthCubit({
    required AuthRepository authRepository,
    ProfileCubit? profileCubit,
  })  : _authRepository = authRepository,
        _profileCubit = profileCubit,
        super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String city,
    required String phoneNumber,
  }) async {
    emit(const AuthRegistering());
    try {
      await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        city: city,
        phoneNumber: phoneNumber,
      );

      // Adaptive routing: inspect backend response message to determine
      // whether OTP email verification is required.
      bool needsOtpVerification = false;
      final repo = _authRepository;
      if (repo is AuthRepositoryImpl && repo.lastRegisterMessage != null) {
        final msg = repo.lastRegisterMessage!.toLowerCase();
        if (msg.contains('otp') ||
            msg.contains('verify') ||
            msg.contains('verification') ||
            msg.contains('email')) {
          needsOtpVerification = true;
        }
      }

      emit(AuthRegistered(email: email, needsOtpVerification: needsOtpVerification));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ── Email Verification (Register) ───────────────────

  Future<void> verifyRegisterEmail({
    required String email,
    required String otpCode,
  }) async {
    emit(const EmailVerificationLoading());
    try {
      await _authRepository.verifyRegisterEmail(
        email: email,
        otpCode: otpCode,
      );
      emit(const EmailVerificationSuccess());
    } catch (e) {
      emit(EmailVerificationFailure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> resendVerificationOtp(String email) async {
    emit(const ResendOtpLoading());
    try {
      await _authRepository.resendVerificationOtp(email);
      emit(const ResendOtpSuccess());
    } catch (e) {
      emit(ResendOtpFailure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // ── Logout ──────────────────────────────────────────

  Future<void> logout() async {
    await _authRepository.logout();
    _profileCubit?.reset(); // Clear profile state on logout
    emit(const AuthInitial());
  }
}
