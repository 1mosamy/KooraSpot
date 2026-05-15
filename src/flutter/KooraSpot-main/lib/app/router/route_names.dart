/// Centralized route name constants.
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String verifyOtp = 'verifyOtp';
  static const String resetPassword = 'resetPassword';
  static const String verifyRegisterOtp = 'verifyRegisterOtp';

  // Player shell
  static const String playerShell = 'player';
  static const String playerHome = 'playerHome';
  static const String playerBookings = 'playerBookings';
  static const String playerSaved = 'playerSaved';
  static const String playerProfile = 'playerProfile';
  static const String playerEditProfile = 'playerEditProfile';

  // Stadium
  static const String stadiumDetails = 'stadiumDetails';

  // Owner shell
  static const String ownerShell = 'owner';
  static const String ownerDashboard = 'ownerDashboard';
  static const String ownerFields = 'ownerFields';
  static const String ownerAddField = 'ownerAddField';
  static const String ownerEditField = 'ownerEditField';
  static const String ownerManageSlots = 'ownerManageSlots';
  static const String ownerProfile = 'ownerProfile';
  static const String ownerEditProfile = 'ownerEditProfile';
  static const String ownerEarnings = 'ownerEarnings';

  // Paths
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String verifyOtpPath = '/forgot-password/verify-otp';
  static const String resetPasswordPath = '/forgot-password/reset-password';
  static const String verifyRegisterOtpPath = '/verify-register-otp';
  static const String playerPath = '/player';
  static const String playerHomePath = 'home';
  static const String playerBookingsPath = 'bookings';
  static const String playerSavedPath = 'saved';
  static const String playerProfilePath = 'profile';
  static const String playerEditProfilePath = '/player/edit-profile';
  static const String stadiumDetailsPath = '/stadiums/:stadiumId';
  static const String ownerPath = '/owner';
  static const String ownerDashboardPath = 'dashboard';
  static const String ownerFieldsPath = 'fields';
  static const String ownerAddFieldPath = '/owner/fields/new';
  static const String ownerEditFieldPath = '/owner/fields/:fieldId/edit';
  static const String ownerManageSlotsPath = '/owner/fields/:fieldId/slots';
  static const String ownerProfilePath = 'profile';
  static const String ownerEditProfilePath = '/owner/edit-profile';
  static const String ownerEarningsPath = 'earnings';
}
