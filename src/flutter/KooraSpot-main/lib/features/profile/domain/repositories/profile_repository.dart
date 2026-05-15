import '../../../auth/domain/entities/user.dart';

/// Profile repository interface.
abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({
    required String fullName,
    required String city,
    String? phonenumber,
  });
  Future<String> uploadProfileImage(String filePath);
}
