import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/storage/user_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Real auth repository implementation using Dio.
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final UserStorage _userStorage;

  AuthRepositoryImpl({
    required Dio dio,
    required TokenStorage tokenStorage,
    required UserStorage userStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _userStorage = userStorage;

  // ── Helpers ───────────────────────────────────────────

  Future<void> _persistUser(UserModel model, {String? cityFallback, bool preserveLocalData = false}) async {
    final city = (model.city?.isNotEmpty == true) ? model.city : cityFallback;
    // ignore: avoid_print
    print('[Auth] Saving user: name=${model.name} email=${model.email} '
        'role=${model.role} city=$city phone=${model.phonenumber} '
        'firstLetter=${model.firstLetter} profileImageUrl=${model.profileImageUrl}');

    // When the server doesn't return an image (null), fall back to the locally
    // cached one — but only when we know it belongs to the same user.
    final imageToSave = model.profileImageUrl ?? (preserveLocalData ? _userStorage.profileImage : null);

    await _userStorage.saveUserData(
      role: model.role,
      id: model.id,
      fullName: model.name.isNotEmpty ? model.name : null,
      email: model.email.isNotEmpty ? model.email : null,
      city: city,
      phonenumber: model.phonenumber,
      profileImage: imageToSave,
      firstLetter: model.firstLetter,
    );
  }

  // ── Login ─────────────────────────────────────────────

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // ignore: avoid_print
    print('[Auth] Login started for email=$email');
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      // Guard: server may return a plain string on bad credentials
      final loginData = response.data;
      if (loginData is String) throw Exception(loginData);
      if (loginData is! Map<String, dynamic>) throw Exception('Unexpected server response during login.');

      final model = UserModel.fromJson(loginData);

      // Determine whether this is the SAME user re-authenticating or a new account.
      final cachedId = _userStorage.userId;
      final isSameUser = cachedId != null && model.id != null && cachedId == model.id;

      if (!isSameUser) {
        // Different (or first) user — wipe all cached data to prevent cross-account bleed.
        // ignore: avoid_print
        print('[Auth] New user detected — clearing cached data');
        await _userStorage.clearAll();
      } else {
        // ignore: avoid_print
        print('[Auth] Same user re-logging in — preserving cached profile data');
      }

      if (model.token != null) {
        await _tokenStorage.saveToken(model.token!);
        // ignore: avoid_print
        print('[Auth] Token saved');
      }
      // preserveLocalData=true when same user so locally uploaded image is kept
      await _persistUser(model, preserveLocalData: isSameUser);
      // ignore: avoid_print
      print('[Auth] AuthAuthenticated emitted for email=${model.email}');

      return model.toEntity();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  // ── Register ──────────────────────────────────────────

  /// Stores the raw response message from the last register call.
  /// Used by AuthCubit for adaptive routing.
  String? lastRegisterMessage;

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String city,
    required String phoneNumber,
  }) async {
    lastRegisterMessage = null;
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'role': role,
          'city': city,
          'phoneNumber': phoneNumber,
        },
      );

      final responseData = response.data;

      // Extract message for adaptive routing
      if (responseData is String) {
        lastRegisterMessage = responseData;
        final lower = responseData.toLowerCase();
        if (lower.contains('success') || lower.contains('registered') || lower.contains('otp') || lower.contains('verify')) {
          return UserModel(name: fullName, email: email, role: role, city: city, phonenumber: phoneNumber)
              .toEntity();
        }
        throw Exception(responseData);
      }
      if (responseData is Map<String, dynamic>) {
        lastRegisterMessage = responseData['message'] as String?;
        final model = UserModel.fromJson(responseData);
        // Do NOT persist user or save token after register.
        return model.toEntity();
      }
      throw Exception('Unexpected server response during registration.');
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  // ── Verify Register Email ─────────────────────────────

  @override
  Future<void> verifyRegisterEmail({
    required String email,
    required String otpCode,
  }) async {
    try {
      await _dio.post(
        ApiConstants.verifyEmail,
        data: {'email': email, 'otpCode': otpCode},
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  // ── Resend Verification OTP ───────────────────────────

  @override
  Future<void> resendVerificationOtp(String email) async {
    try {
      await _dio.post(
        ApiConstants.resendVerificationOtp,
        data: {'email': email},
      );
    } on DioException catch (e) {
      // Gracefully handle if endpoint is not implemented (404/405)
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        throw Exception(
          'Resend OTP is not available right now. Please try registering again or check your email.',
        );
      }
      throw Exception(ApiError.fromDioException(e));
    }
  }

  // ── Logout ────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    await _userStorage.clearAll();
    // ignore: avoid_print
    print('[Auth] Logout completed — all session data cleared');
  }

  @override
  Future<bool> isLoggedIn() async => _tokenStorage.hasToken();

  @override
  Future<String?> getSavedRole() async => _userStorage.role;
}
