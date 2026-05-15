import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants/storage_keys.dart';

/// SharedPreferences wrapper for user profile cache.
class UserStorage {
  final SharedPreferences _prefs;

  UserStorage(this._prefs);

  // ── Save ──────────────────────────────────────────────
  Future<void> saveUserData({
    required String role,
    String? id,
    String? fullName,
    String? email,
    String? city,
    String? phonenumber,
    String? profileImage,
    String? firstLetter,
  }) async {
    await _prefs.setString(StorageKeys.userRole, role);
    if (id != null) await _prefs.setString(StorageKeys.userId, id);
    if (fullName != null) await _prefs.setString(StorageKeys.userFullName, fullName);
    if (email != null) await _prefs.setString(StorageKeys.userEmail, email);
    if (city != null) await _prefs.setString(StorageKeys.userCity, city);
    if (phonenumber != null) await _prefs.setString(StorageKeys.userPhoneNumber, phonenumber);
    if (profileImage != null) await _prefs.setString(StorageKeys.userProfileImage, profileImage);
    if (firstLetter != null) await _prefs.setString(StorageKeys.userFirstLetter, firstLetter);
  }

  // ── Read ──────────────────────────────────────────────
  String? get role => _prefs.getString(StorageKeys.userRole);
  String? get userId => _prefs.getString(StorageKeys.userId);
  String? get fullName => _prefs.getString(StorageKeys.userFullName);
  String? get email => _prefs.getString(StorageKeys.userEmail);
  String? get city => _prefs.getString(StorageKeys.userCity);
  String? get phonenumber => _prefs.getString(StorageKeys.userPhoneNumber);
  String? get profileImage => _prefs.getString(StorageKeys.userProfileImage);
  String? get firstLetter => _prefs.getString(StorageKeys.userFirstLetter);

  bool get isPlayer => role == 'Player';
  bool get isOwner => role == 'Owner';

  // ── Clear ─────────────────────────────────────────────

  /// Clears all stored user data. Called on logout and before new login.
  Future<void> clearAll() async {
    await _prefs.remove(StorageKeys.userRole);
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userFullName);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.remove(StorageKeys.userCity);
    await _prefs.remove(StorageKeys.userPhoneNumber);
    await _prefs.remove(StorageKeys.userProfileImage);
    await _prefs.remove(StorageKeys.userFirstLetter);
  }

  /// Alias for clearAll — used on logout.
  Future<void> clearSession() => clearAll();
}
