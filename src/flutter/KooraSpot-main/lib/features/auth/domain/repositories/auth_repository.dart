import '../entities/user.dart';

/// Auth repository interface.
abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  Future<User> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String city,
    required String phoneNumber,
  });

  /// Verify email after registration via POST /Users/verify-email.
  Future<void> verifyRegisterEmail({
    required String email,
    required String otpCode,
  });

  /// Resend verification OTP to the given email.
  /// May throw if the endpoint is not available (404/405).
  Future<void> resendVerificationOtp(String email);

  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getSavedRole();
}
