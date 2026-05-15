import 'package:dio/dio.dart';

/// Parses DioException into user-friendly error messages.
class ApiError {
  static String fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) return 'Server error occurred.';

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (statusCode == 400) {
      if (data is Map<String, dynamic>) {
        // Check for validation errors
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.cast<String>());
            } else {
              messages.add(value.toString());
            }
          });
          return messages.join('\n');
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('title')) {
          return data['title'].toString();
        }
      }
      return 'Invalid request. Please check your input.';
    }

    if (statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }

    if (statusCode == 404) {
      return 'The requested resource was not found.';
    }

    if (statusCode >= 500) {
      return 'Server error. Please try again later.';
    }

    return 'Error occurred (status: $statusCode).';
  }

  /// Extract field-level validation errors from response.
  static Map<String, dynamic>? extractFieldErrors(Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      if (data.containsKey('errors')) {
        return data['errors'] as Map<String, dynamic>;
      }
    }
    return null;
  }
}
