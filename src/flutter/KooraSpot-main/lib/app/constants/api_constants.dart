/// Centralized API endpoint constants.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://kooraspot.runasp.net';

  // ── Auth ─────────────────────────────────────────────────
  static const String register = '/api/Users/register';
  static const String login = '/api/Users/login';

  // ── Register Email Verification ──────────────────────
  /// POST /Users/verify-email — for verifying email after register.
  static const String verifyEmail = '/api/Users/verify-email';
  static const String resendVerificationOtp =
      '/api/Users/resend-verification-email';

  // ── Forgot Password OTP ─────────────────────────────
  /// POST /Users/forgot-password — sends OTP for password recovery.
  static const String forgotPassword = '/api/Users/forgot-password';
  /// POST /Users/verify-otp — verifies OTP for forgot password flow only.
  static const String verifyOtp = '/api/Users/verify-reset-otp';
  /// POST /Users/reset-password — resets password with verified OTP.
  static const String resetPassword = '/api/Users/reset-password';

  // ── Profile ──────────────────────────────────────────────
  static const String profile = '/api/Users/profile';
  static const String uploadProfileImage = '/api/Users/upload-profile-image';

  // ── Fields  ───────────────────────────────────────────────
  static const String fields = '/api/Fields';
  static String fieldById(int id) => '/api/Fields/$id';
  static const String myFields = '/api/Fields/my-fields';
  static String fieldSlots(int fieldId) => '/api/Fields/$fieldId/slots';

  // ── Fields (update / toggle / delete) ──────────────────
  static String updateField(int id) => '/api/Fields/$id';
  static String toggleFieldActive(int id) => '/api/Fields/$id/toggle-active';
  static String deleteField(int id) => '/api/Fields/$id';

  // ── Favorites ──────────────────────────────────────────
  static const String favorites = '/api/Favorites';
  static String favoriteField(int fieldId) => '/api/Favorites/$fieldId';

  // ── Bookings ─────────────────────────────────────────────
  static const String bookings = '/api/Bookings';
  static const String myBookings = '/api/Bookings/my';
  static String fieldBookings(int fieldId) => '/api/Bookings/field/$fieldId';

  // ── Payments ───────────────────────────────────────────
  static const String createCheckoutSession =
      '/api/Payments/create-checkout-session';

  // ── Owner Wallet ───────────────────────────────────────
  static const String ownerWalletSummary = '/api/OwnerWallet/summary';
  static const String ownerWalletWithdraw = '/api/OwnerWallet/withdraw';
  static const String ownerWalletWithdrawals = '/api/OwnerWallet/withdrawals';

  // ── URL helpers ──────────────────────────────────────────
  /// Converts a relative image path to a full URL.
  static String? normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }
}
