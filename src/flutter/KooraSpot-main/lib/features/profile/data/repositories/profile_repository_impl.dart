import 'package:dio/dio.dart';

import '../../../../app/constants/api_constants.dart';
import '../../../../core/network/api_error.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

/// Real profile repository using Dio.
class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  ProfileRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<User> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return UserModel.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<User> updateProfile({
    required String fullName,
    required String city,
    String? phonenumber,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.profile,
        data: {
          'fullName': fullName, // backend update endpoint uses fullName
          'name': fullName,     // also send 'name' in case backend switches
          'city': city,
          if (phonenumber != null) 'phonenumber': phonenumber,
        },
      );
      // The API might not return a full user object here, or it might return the updated fields.
      return UserModel.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        ApiConstants.uploadProfileImage,
        data: formData,
      );

      // Log full response to identify the correct field name
      // ignore: avoid_print
      print('[uploadProfileImage] Raw response: ${response.data}');

      final data = response.data as Map<String, dynamic>? ?? {};
      // Try root-level fields first
      String rootUrl = (data['profileImageUrl'] ?? data['imageUrl'] ?? data['url'] ?? data['image'])?.toString() ?? '';
      if (rootUrl.isNotEmpty) {
        return _normalizeUrl(rootUrl);
      }

      // Try nested under 'user'
      final userData = data['user'] as Map<String, dynamic>?;
      if (userData != null) {
        String nestedUrl = (userData['profileImageUrl'] ?? userData['imageUrl'] ?? userData['url'] ?? userData['image'])?.toString() ?? '';
        if (nestedUrl.isNotEmpty) {
          return _normalizeUrl(nestedUrl);
        }
      }

      return '';
    } on DioException catch (e) {
      throw Exception(ApiError.fromDioException(e));
    }
  }

  /// Converts a relative path like /images/users/xxx.webp to a full URL.
  String _normalizeUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConstants.baseUrl}$url';
    return '${ApiConstants.baseUrl}/$url';
  }
}
