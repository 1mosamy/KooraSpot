import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/forgot_password_repository.dart';

/// Dio-based implementation of the forgot-password / OTP flow.
/// None of these endpoints require an auth token.
class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final Dio _dio;

  ForgotPasswordRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<void> sendOtp(String email) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      await _dio.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otpCode': otpCode},
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otpCode': otpCode,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }
}
