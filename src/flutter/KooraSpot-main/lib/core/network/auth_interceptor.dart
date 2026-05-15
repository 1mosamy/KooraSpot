import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Interceptor that adds Authorization header and handles 401 responses.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    this.onUnauthorized,
  }) : _tokenStorage = tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _tokenStorage.deleteToken();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
