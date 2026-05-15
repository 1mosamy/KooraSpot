import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/constants/storage_keys.dart';

/// Wrapper around FlutterSecureStorage for JWT token management.
class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getToken() async {
    return _storage.read(key: StorageKeys.authToken);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
