/// Keys for secure and shared preferences storage.
class StorageKeys {
  StorageKeys._();

  // FlutterSecureStorage keys
  static const String authToken = 'auth_token';

  // SharedPreferences keys
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String userFullName = 'user_full_name';
  static const String userEmail = 'user_email';
  static const String userCity = 'user_city';
  static const String userPhoneNumber = 'user_phone_number';
  static const String userProfileImage = 'user_profile_image';
  static const String userFirstLetter = 'user_first_letter';
  static const String isFirstLaunch = 'is_first_launch';
}
