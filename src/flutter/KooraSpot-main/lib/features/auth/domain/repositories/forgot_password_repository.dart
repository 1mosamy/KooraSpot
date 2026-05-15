/// Forgot password flow repository interface.
abstract class ForgotPasswordRepository {
  /// Sends an OTP to the given email.
  Future<void> sendOtp(String email);

  /// Verifies the OTP code for the given email.
  Future<void> verifyOtp({required String email, required String otpCode});

  /// Resets the password using the verified OTP.
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  });
}
